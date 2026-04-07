#!/usr/bin/env node

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const BASE_URL = "https://api.hyperliquid.xyz";

// --- Shared fetch helper ---

async function hlInfo(body) {
  const res = await fetch(`${BASE_URL}/info`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Hyperliquid API ${res.status}: ${text}`);
  }
  return res.json();
}

function ok(data) {
  return { content: [{ type: "text", text: JSON.stringify(data, null, 2) }] };
}

function err(msg) {
  return { content: [{ type: "text", text: `Error: ${msg}` }], isError: true };
}

// --- Server setup ---

const server = new McpServer({
  name: "hyperliquid",
  version: "1.0.0",
});

// 1. Meta — universe info, asset list, margin params
server.tool(
  "get_meta",
  "Get Hyperliquid perpetuals universe metadata: all listed assets, margin parameters, and exchange config",
  {},
  async () => {
    try {
      const data = await hlInfo({ type: "meta" });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 2. Meta + Asset Contexts — prices, funding, OI, volume for every asset
server.tool(
  "get_asset_contexts",
  "Get all perpetual assets with live context: mark price, mid price, oracle price, funding rate, open interest, 24h volume, premium. This is the richest single-call overview of the exchange.",
  {},
  async () => {
    try {
      const data = await hlInfo({ type: "metaAndAssetCtxs" });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 3. All mid prices
server.tool(
  "get_all_mids",
  "Get current mid prices for all listed assets. Lightweight — use this for a quick price check across the whole exchange.",
  {},
  async () => {
    try {
      const data = await hlInfo({ type: "allMids" });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 4. L2 Order Book
server.tool(
  "get_l2_book",
  "Get the L2 order book (bids and asks) for a specific asset. Returns up to 20 price levels per side.",
  {
    coin: z.string().describe("Asset symbol, e.g. 'BTC', 'ETH', 'SOL'"),
    nSigFigs: z
      .number()
      .optional()
      .describe("Number of significant figures for price grouping (2-5)"),
  },
  async ({ coin, nSigFigs }) => {
    try {
      const body = { type: "l2Book", coin };
      if (nSigFigs) body.nSigFigs = nSigFigs;
      const data = await hlInfo(body);
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 5. User State (Clearinghouse) — positions, margin, account value
server.tool(
  "get_user_state",
  "Get a wallet's perpetual positions, margin summary, and account value. Essential for copy trading analysis — see what any wallet is holding.",
  {
    user: z
      .string()
      .describe("Ethereum address (0x...) of the wallet to inspect"),
  },
  async ({ user }) => {
    try {
      const data = await hlInfo({ type: "clearinghouseState", user });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 6. Open Orders
server.tool(
  "get_open_orders",
  "Get all open orders for a wallet. Use frontendOpenOrders for richer metadata.",
  {
    user: z.string().describe("Ethereum address (0x...)"),
  },
  async ({ user }) => {
    try {
      const data = await hlInfo({ type: "frontendOpenOrders", user });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 7. User Fills (Recent Trades)
server.tool(
  "get_user_fills",
  "Get recent trade fills for a wallet (up to 2000). Shows execution history — what a trader actually bought/sold, at what price, and when.",
  {
    user: z.string().describe("Ethereum address (0x...)"),
    aggregateByTime: z
      .boolean()
      .optional()
      .describe("Aggregate fills that occur at the same time (default false)"),
  },
  async ({ user, aggregateByTime }) => {
    try {
      const data = await hlInfo({
        type: "userFills",
        user,
        aggregateByTime: aggregateByTime ?? false,
      });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 8. User Fills by Time Range
server.tool(
  "get_user_fills_by_time",
  "Get trade fills for a wallet within a specific time range. Useful for analyzing a trader's activity over a period.",
  {
    user: z.string().describe("Ethereum address (0x...)"),
    startTime: z.number().describe("Start time in milliseconds since epoch"),
    endTime: z
      .number()
      .optional()
      .describe("End time in milliseconds since epoch (default: now)"),
  },
  async ({ user, startTime, endTime }) => {
    try {
      const body = { type: "userFillsByTime", user, startTime };
      if (endTime) body.endTime = endTime;
      const data = await hlInfo(body);
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 9. Funding History
server.tool(
  "get_funding_history",
  "Get historical funding rates for an asset over a time range. Funding is paid every hour on Hyperliquid.",
  {
    coin: z.string().describe("Asset symbol, e.g. 'BTC'"),
    startTime: z.number().describe("Start time in milliseconds since epoch"),
    endTime: z
      .number()
      .optional()
      .describe("End time in milliseconds since epoch"),
  },
  async ({ coin, startTime, endTime }) => {
    try {
      const body = { type: "fundingHistory", coin, startTime };
      if (endTime) body.endTime = endTime;
      const data = await hlInfo(body);
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 10. Predicted Fundings
server.tool(
  "get_predicted_fundings",
  "Get predicted funding rates for the next funding period across all assets.",
  {},
  async () => {
    try {
      const data = await hlInfo({ type: "predictedFundings" });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 11. Candle/OHLCV Data
server.tool(
  "get_candles",
  "Get OHLCV candlestick data for an asset. Intervals: 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 8h, 12h, 1d, 3d, 1w, 1M. Max 5000 candles per request.",
  {
    coin: z.string().describe("Asset symbol, e.g. 'BTC'"),
    interval: z
      .string()
      .describe(
        "Candle interval: 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 8h, 12h, 1d, 3d, 1w, 1M"
      ),
    startTime: z.number().describe("Start time in milliseconds since epoch"),
    endTime: z
      .number()
      .optional()
      .describe("End time in milliseconds since epoch (default: now)"),
  },
  async ({ coin, interval, startTime, endTime }) => {
    try {
      const req = { coin, interval, startTime };
      if (endTime) req.endTime = endTime;
      const data = await hlInfo({ type: "candleSnapshot", req });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 12. Spot Meta
server.tool(
  "get_spot_meta",
  "Get Hyperliquid spot market metadata: all spot tokens, trading pairs, and decimals.",
  {},
  async () => {
    try {
      const data = await hlInfo({ type: "spotMetaAndAssetCtxs" });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 13. User Spot State
server.tool(
  "get_user_spot_state",
  "Get a wallet's spot token balances on Hyperliquid.",
  {
    user: z.string().describe("Ethereum address (0x...)"),
  },
  async ({ user }) => {
    try {
      const data = await hlInfo({ type: "spotClearinghouseState", user });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 14. Vault Details
server.tool(
  "get_vault_details",
  "Get details about a Hyperliquid vault: strategy, performance, depositors, and positions.",
  {
    vaultAddress: z.string().describe("Vault address (0x...)"),
  },
  async ({ vaultAddress }) => {
    try {
      const data = await hlInfo({ type: "vaultDetails", vaultAddress });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 15. User Portfolio (PnL history)
server.tool(
  "get_portfolio",
  "Get a wallet's portfolio and historical PnL data.",
  {
    user: z.string().describe("Ethereum address (0x...)"),
  },
  async ({ user }) => {
    try {
      const data = await hlInfo({ type: "portfolio", user });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 16. Sub-Accounts
server.tool(
  "get_sub_accounts",
  "Get all sub-accounts for a master wallet.",
  {
    user: z.string().describe("Master wallet address (0x...)"),
  },
  async ({ user }) => {
    try {
      const data = await hlInfo({ type: "subAccounts", user });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 17. Perps at Open Interest Cap
server.tool(
  "get_perps_at_oi_cap",
  "Get list of perpetual contracts currently at their open interest cap.",
  {},
  async () => {
    try {
      const data = await hlInfo({ type: "perpsAtOpenInterestCap" });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// 18. User Fees
server.tool(
  "get_user_fees",
  "Get trading fee rates for a wallet (maker/taker, volume tiers, referral discounts).",
  {
    user: z.string().describe("Ethereum address (0x...)"),
  },
  async ({ user }) => {
    try {
      const data = await hlInfo({ type: "userFees", user });
      return ok(data);
    } catch (e) {
      return err(e.message);
    }
  }
);

// --- Start server ---

const transport = new StdioServerTransport();
await server.connect(transport);
