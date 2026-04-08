#!/usr/bin/env node
/**
 * Stitch MCP Proxy — zero-dependency bridge
 *
 * Bridges Google Stitch's HTTP MCP API to local stdio MCP protocol.
 * Responds to `initialize` INSTANTLY (before connecting to Stitch)
 * so Claude Code doesn't time out waiting for the handshake.
 *
 * Bypasses @_davideast/stitch-mcp proxy bug where the bundled
 * MCP SDK connects to Stitch but never relays responses to stdout.
 *
 * Usage: STITCH_API_KEY=xxx node stitch-proxy.mjs
 */

const STITCH_URL = process.env.STITCH_MCP_URL || 'https://stitch.googleapis.com/mcp';
const API_KEY = process.env.STITCH_API_KEY;

if (!API_KEY) {
  process.stderr.write('[stitch-proxy] ERROR: STITCH_API_KEY not set\n');
  process.exit(1);
}

// --- State ---
let remoteTools = [];
let stitchReady = false;
let stitchError = null;
let pendingToolsList = []; // Queued tools/list requests waiting for Stitch

// --- Stitch HTTP API ---
async function forwardToStitch(method, params) {
  const res = await fetch(STITCH_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Goog-Api-Key': API_KEY
    },
    body: JSON.stringify({ jsonrpc: '2.0', id: 1, method, params: params || {} })
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Stitch API ${res.status}: ${text.slice(0, 200)}`);
  }
  return res.json();
}

// Connect to Stitch in background (non-blocking)
async function initStitch() {
  try {
    process.stderr.write(`[stitch-proxy] Connecting to ${STITCH_URL}...\n`);
    await forwardToStitch('initialize', {
      protocolVersion: '2024-11-05',
      capabilities: {},
      clientInfo: { name: 'stitch-proxy', version: '2.0.0' }
    });
    // Fire-and-forget notification
    fetch(STITCH_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'X-Goog-Api-Key': API_KEY },
      body: JSON.stringify({ jsonrpc: '2.0', method: 'notifications/initialized' })
    }).catch(() => {});
    // Fetch tools
    const result = await forwardToStitch('tools/list', {});
    remoteTools = result?.result?.tools || [];
    stitchReady = true;
    process.stderr.write(`[stitch-proxy] Connected, discovered ${remoteTools.length} tools\n`);
    // Flush any queued tools/list requests
    for (const { id } of pendingToolsList) {
      send({ jsonrpc: '2.0', id, result: { tools: remoteTools } });
    }
    pendingToolsList = [];
  } catch (err) {
    stitchError = err.message;
    process.stderr.write(`[stitch-proxy] Connection failed: ${err.message}\n`);
    // Flush pending with error
    for (const { id } of pendingToolsList) {
      send({ jsonrpc: '2.0', id, error: { code: -32000, message: `Stitch unavailable: ${err.message}` } });
    }
    pendingToolsList = [];
  }
}

// --- Message handling ---
function handleMessage(msg) {
  const { id, method, params } = msg;

  switch (method) {
    case 'initialize':
      // Respond INSTANTLY — no waiting for Stitch
      return {
        jsonrpc: '2.0',
        id,
        result: {
          protocolVersion: '2024-11-05',
          capabilities: { tools: {} },
          serverInfo: { name: 'stitch-proxy', version: '2.0.0' }
        }
      };

    case 'notifications/initialized':
      return null; // No response for notifications

    case 'tools/list':
      if (stitchReady) {
        return { jsonrpc: '2.0', id, result: { tools: remoteTools } };
      }
      if (stitchError) {
        return { jsonrpc: '2.0', id, error: { code: -32000, message: `Stitch unavailable: ${stitchError}` } };
      }
      // Queue — will be flushed when Stitch connects
      pendingToolsList.push({ id });
      return null;

    case 'tools/call':
      return forwardToolCall(id, params);

    case 'ping':
      return { jsonrpc: '2.0', id, result: {} };

    default:
      return { jsonrpc: '2.0', id, error: { code: -32601, message: `Method not found: ${method}` } };
  }
}

async function forwardToolCall(id, params) {
  if (!stitchReady) {
    return { jsonrpc: '2.0', id, error: { code: -32000, message: 'Stitch not yet connected' } };
  }
  try {
    const resp = await forwardToStitch('tools/call', params);
    return {
      jsonrpc: '2.0',
      id,
      result: resp?.result || { content: [{ type: 'text', text: JSON.stringify(resp) }] }
    };
  } catch (err) {
    return { jsonrpc: '2.0', id, error: { code: -32000, message: err.message } };
  }
}

// --- stdio transport ---
function send(msg) {
  if (msg) {
    process.stdout.write(JSON.stringify(msg) + '\n');
  }
}

let buffer = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', async (chunk) => {
  buffer += chunk;
  const lines = buffer.split('\n');
  buffer = lines.pop();
  for (const line of lines) {
    if (!line.trim()) continue;
    try {
      const msg = JSON.parse(line);
      const response = handleMessage(msg);
      if (response instanceof Promise) {
        send(await response);
      } else {
        send(response);
      }
    } catch (err) {
      process.stderr.write(`[stitch-proxy] Parse error: ${err.message}\n`);
    }
  }
});

// --- Start ---
// 1. Begin listening on stdin IMMEDIATELY (above)
// 2. Connect to Stitch in background (non-blocking)
process.stderr.write('[stitch-proxy] Starting (stdin ready, connecting to Stitch in background)...\n');
initStitch();
