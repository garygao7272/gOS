---
name: market-regime
description: Monitor crypto market regime changes every 6 hours
schedule: "0 3,9,15,21 * * *"
trigger: cron
model: haiku
---

# Market Regime Claw

## Purpose
Track crypto market regime (risk-on, risk-off, transition, choppy) using Hyperliquid MCP data. Alert on regime changes.

## Execution Steps

1. Read `state.json` for previous regime and history
2. Fetch current market data via Hyperliquid MCP:
   - `get_tickers` for BTC, ETH top-level price/volume
   - `get_candlestick` for BTC with timeframe "1d" (last 7 days)
   - `get_candlestick` for ETH with timeframe "1d" (last 7 days)
3. Calculate regime indicators:
   - **Trend**: 7-day price direction (up/down/flat)
   - **Volatility**: Average daily range as % of price
   - **Volume**: Current vs 7-day average (expanding/contracting)
   - **BTC/ETH correlation**: Moving in sync or diverging
4. Classify regime:
   - **risk-on**: Trend up + volume expanding + low volatility
   - **risk-off**: Trend down + volume expanding + high volatility
   - **transition**: Regime indicators mixed, changing from previous state
   - **choppy**: No clear trend + high volatility + volume contracting
5. Compare to `state.json.current_regime`:
   - If different: flag regime change, record transition
   - If same: update confidence level
6. Write `state.json`

## Output Format (in state.json)

```json
{
  "last_run": "ISO timestamp",
  "run_count": 0,
  "current_regime": "risk-on",
  "regime_confidence": 0.85,
  "regime_since": "ISO timestamp",
  "indicators": {
    "btc_price": 0,
    "eth_price": 0,
    "btc_7d_change_pct": 0,
    "eth_7d_change_pct": 0,
    "avg_daily_range_pct": 0,
    "volume_vs_avg": 0,
    "btc_eth_correlation": 0
  },
  "regime_history": [
    {
      "regime": "risk-on",
      "from": "ISO timestamp",
      "to": "ISO timestamp",
      "duration_hours": 0
    }
  ],
  "alert": null,
  "last_digest": null
}
```

## Surfacing in /gos Briefing

No regime change:
```
Claws > market-regime: risk-on (85% confidence, 3 days)
  BTC $68,420 (+4.2% 7d) | ETH $3,850 (+5.1% 7d) | Vol: normal
```

Regime change detected:
```
!! Claws > market-regime: REGIME CHANGE: risk-on → transition
  BTC $65,200 (-2.1% 24h) | ETH $3,620 (-3.4% 24h) | Vol: expanding
  Previous regime lasted 12 days. Review /simulate market for scenarios.
```

## Token Budget
Max 2,000 tokens per run. Uses Hyperliquid MCP directly — no web searches needed.
