---
effort: medium
description: "Financial services routing — 5 plugins, 41 skills, 38 commands"
---

# Finance — Financial Services Arm

Routes to Anthropic's financial-services-plugins. Parse the sub-command to route:

## Routing Table

| Sub-command                   | Plugin             | Skill                  | What It Does                                               |
| ----------------------------- | ------------------ | ---------------------- | ---------------------------------------------------------- |
| **Modeling**                  |                    |                        |                                                            |
| `model`                       | financial-analysis | `xlsx`                 | Build/edit Excel financial models (auto-triggers on .xlsx) |
| `comps <company>`             | financial-analysis | `comps-analysis`       | Comparable company analysis with trading multiples         |
| `dcf <company>`               | financial-analysis | `dcf-model`            | DCF valuation with WACC, sensitivity tables                |
| `lbo <company>`               | financial-analysis | `lbo-model`            | LBO model for PE acquisition                               |
| `3stmt`                       | financial-analysis | `3-statement-model`    | Fill out IS/BS/CF model template                           |
| `unit-econ`                   | private-equity     | `unit-economics`       | ARR cohorts, LTV/CAC, retention analysis                   |
| `returns`                     | private-equity     | `returns`              | IRR/MOIC sensitivity tables                                |
| **Audit & QA**                |                    |                        |                                                            |
| `audit <file>`                | financial-analysis | `audit-xls`            | Audit spreadsheet for formula errors, logic issues         |
| `check-deck <file>`           | financial-analysis | `ib-check-deck`        | QC presentation for number consistency, language           |
| `clean <file>`                | financial-analysis | `clean-data-xls`       | Clean messy spreadsheet data                               |
| **Presentations**             |                    |                        |                                                            |
| `deck <topic>`                | financial-analysis | `competitive-analysis` | Competitive landscape deck                                 |
| `pitch <company>`             | investment-banking | `pitch-deck`           | Populate pitch deck template with data                     |
| `one-pager <company>`         | investment-banking | `strip-profile`        | One-page company strip profile                             |
| `refresh <file>`              | financial-analysis | `deck-refresh`         | Update deck with new numbers                               |
| **Deal Materials**            |                    |                        |                                                            |
| `cim`                         | investment-banking | `cim`                  | Draft Confidential Information Memorandum                  |
| `teaser`                      | investment-banking | `teaser`               | Draft anonymous one-page teaser                            |
| `buyer-list`                  | investment-banking | `buyer-list`           | Build buyer universe for sell-side process                 |
| `merger <target>`             | investment-banking | `merger-model`         | Accretion/dilution merger model                            |
| `deal-tracker`                | investment-banking | `deal-tracker`         | Track live deal pipeline                                   |
| `datapack <source>`           | investment-banking | `datapack-builder`     | Build data pack from CIM/filings/web                       |
| **Research**                  |                    |                        |                                                            |
| `earnings <company>`          | equity-research    | `earnings-analysis`    | Post-earnings update report                                |
| `initiate <company>`          | equity-research    | `initiating-coverage`  | Initiating coverage report (5-task workflow)               |
| `thesis <company>`            | equity-research    | `thesis`               | Create/update investment thesis                            |
| `sector <industry>`           | equity-research    | `sector`               | Sector overview report                                     |
| `screen <criteria>`           | equity-research    | `screen`               | Stock screen / investment ideas                            |
| `catalysts`                   | equity-research    | `catalysts`            | View/update catalyst calendar                              |
| `morning-note`                | equity-research    | `morning-note`         | Draft morning meeting note                                 |
| **PE / VC**                   |                    |                        |                                                            |
| `source <criteria>`           | private-equity     | `source`               | Source deals, discover companies, draft outreach           |
| `screen-deal <file>`          | private-equity     | `screen-deal`          | Screen inbound deal (CIM or teaser)                        |
| `dd-checklist`                | private-equity     | `dd-checklist`         | Generate due diligence checklist                           |
| `ic-memo`                     | private-equity     | `ic-memo`              | Draft investment committee memo                            |
| `portfolio`                   | private-equity     | `portfolio`            | Review portfolio company performance                       |
| `value-creation`              | private-equity     | `value-creation`       | Post-acquisition value creation plan                       |
| `ai-readiness`                | private-equity     | `ai-readiness`         | Scan portfolio for AI opportunities                        |
| `dd-prep`                     | private-equity     | `dd-prep`              | Prep for diligence meeting or expert call                  |
| **Wealth**                    |                    |                        |                                                            |
| `client-review`               | wealth-management  | `client-review`        | Prep for client review meeting                             |
| `rebalance`                   | wealth-management  | `rebalance`            | Analyze drift, generate rebalancing trades                 |
| `tlh`                         | wealth-management  | `tlh`                  | Tax-loss harvesting opportunities                          |
| `client-report`               | wealth-management  | `client-report`        | Generate client performance report                         |
| `proposal <prospect>`         | wealth-management  | `proposal`             | Investment proposal for prospect                           |
| `plan`                        | wealth-management  | `financial-plan`       | Build/update financial plan                                |

## Execution

When a sub-command is matched:
1. Invoke the skill via `Skill("plugin:skill-name")` or `Skill("plugin-name:skill-name")`
2. Pass the remaining arguments as skill args
3. The skill handles all interaction, output, and formatting

**No sub-command?** Show the routing table and ask: "Which financial workflow?"

## Arx-Specific Shortcuts

| Shortcut       | Expands To                                                      |
| -------------- | --------------------------------------------------------------- |
| `projections`  | `xlsx` → build/update Arx financial projections                 |
| `fundraise`    | `ic-memo` + `one-pager` + `financial-plan` → investor materials |
| `competitive`  | `competitive-analysis` + `comps` → competitive landscape        |
| `diligence`    | `dd-checklist` + `unit-econ` + `returns` → investor DD prep     |
