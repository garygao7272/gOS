---
name: hyperliquid-market-pulse
description: Weekly Hyperliquid market snapshot — top movers, funding rates, OI changes
---

Generate a weekly Hyperliquid market pulse report. Use the Hyperliquid MCP tools to:
1. Get all mid prices (get_all_mids) and identify top 5 movers by comparing to typical ranges
2. Get predicted funding rates (get_predicted_fundings) and flag any extreme rates (>0.05% or <-0.05%)
3. Get asset contexts (get_asset_contexts) for top 10 assets by open interest
4. Check perps at OI cap (get_perps_at_oi_cap) for capacity constraints

Summarize findings in a concise market pulse format. Save the report to /Users/garyg/Documents/Claude Working Folder/Arx/outputs/market-pulse-{date}.md where {date} is today's date in YYYY-MM-DD format.