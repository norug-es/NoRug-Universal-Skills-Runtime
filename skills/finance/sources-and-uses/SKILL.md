---
name: sources-and-uses
version: 1.0.0-chatgpt
domain: transactions
portable: true
dependencies: []
triggers: ["sources and uses", "transaction funding", "purchase price funding"]
description: Builds a transaction Sources and Uses .xlsx from scratch with live formulas across separate inputs/calculations/outputs tabs plus checks, with an equity plug that balances the table and a pro forma capitalization with leverage multiples by tranche. Use when someone wants a downloadable funding table for a deal.
---
## ChatGPT execution contract

- **Runtime:** Treat this file as domain methodology and an execution contract, not as a dependency on a specific model vendor.
- **Workbook engine:** When creating or editing `.xlsx`, use the spreadsheet tooling available in the current ChatGPT environment. Follow the environment's native spreadsheet skill/instructions first.
- **No false verification:** Never claim formulas were recalculated, charts rendered, or checks passed unless the runtime actually verified them. If calculation support is unavailable, perform structural validation and state that Excel/Google Sheets must refresh cached formula values.
- **Inputs vs formulas:** Keep user-editable assumptions separate from derived calculations. Never embed avoidable magic numbers inside formulas.
- **Finance formatting:** Default to blue hardcodes, black same-sheet formulas, green cross-sheet links, red external-file links, yellow attention assumptions; format zeros as `-`, negatives red and in parentheses, multiples as `0.0x`, and always state units.
- **Source provenance:** For researched financial inputs, prefer primary sources and place source URLs in cell comments (or a dedicated source field where comments are unavailable).
- **QA gate:** Scan key ranges for broken references and formula errors; verify model-specific tie-outs; inspect important output ranges; validate visual layout before export.
- **Preservation rule:** If editing an existing workbook, preserve its structure and style unless the user explicitly requests a rebuild or redesign.


# Sources and Uses

## When to use
Use when the user wants a new transaction funding table: a Uses side (purchase equity, refinanced debt, fees, minimum cash) funded by a Sources side (new debt tranches, rollover equity, cash on hand, and a sponsor/new-equity plug), plus a pro forma capitalization table with leverage multiples by tranche. The equity plug is what makes Sources equal Uses. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling. It should produce a standalone workbook without requiring an Excel add-in.

## What it builds
Tabs: Cover (legend), Assumptions (blue inputs: purchase price, existing debt, fee rates, EBITDA, leverage by tranche, rates), Sources & Uses (the funding table with the equity plug), Pro Forma Cap Table (tranche stack with leverage multiples), Checks. Inputs live only on Assumptions.

## Build workflow
1. Create the five tabs.
2. On Assumptions, enter purchase equity value or entry EV, existing debt to refinance, transaction and financing fee rates, minimum cash, LTM EBITDA, leverage turns per tranche, and tranche rates. Name key ranges.
3. Build the Uses side (all dollars going out).
4. Build the Sources side, sizing debt tranches off EBITDA turns, then add rollover equity and cash on hand.
5. Set sponsor/new equity as the balancing plug: Total Uses less all other sources.
6. Build the Pro Forma Cap Table with cumulative debt and leverage multiples by tranche.
7. Wire Checks; apply formatting and the cover legend.
8. Recalculate the workbook headless.
9. Verify zero formula errors and Sources = Uses, then deliver the .xlsx.

## Tab-by-tab spec
Single-column transaction snapshot. One consistent formula per line.

Assumptions
- Entry EV or purchase equity, existing debt balance, transaction fee %, financing fee %, minimum cash, LTM EBITDA, leverage turns per tranche, rate per tranche, rollover equity %, cash on hand available.

Uses
- Purchase equity (or entry EV): `=Assumptions!PurchaseEquity`.
- Refinance existing debt: `=Assumptions!ExistingDebt`.
- Transaction fees: `=Assumptions!EntryEV*Assumptions!TxnFeePct`.
- Financing fees: `=SUM(NewDebtTranches)*Assumptions!FinFeePct`.
- Minimum cash to balance sheet: `=Assumptions!MinCash`.
- Total Uses: `=SUM(Uses items)`.

Sources
- Each new debt tranche: `=Assumptions!EBITDA*Assumptions!Tranche_x_Turns`.
- Rollover equity: `=Assumptions!PurchaseEquity*Assumptions!RolloverPct`.
- Cash on hand: `=Assumptions!CashOnHand`.
- Sponsor/new equity (plug): `=TotalUses - SUM(NewDebtTranches) - RolloverEquity - CashOnHand`.
- Total Sources: `=SUM(Sources items)`.

Pro Forma Cap Table
- Per tranche: amount, `xEBITDA` multiple `=TrancheAmount/Assumptions!EBITDA`, and cumulative leverage `=CumulativeDebtThroughTranche/Assumptions!EBITDA`.
- Total debt, less minimum cash = net debt; net leverage `=NetDebt/Assumptions!EBITDA`.
- Equity (sponsor + rollover) and total capitalization; equity % of total cap.

## Formula and formatting conventions
Blue = inputs (Assumptions/Cover only). Black = in-tab formulas. Green = cross-tab links. Never hardcode a constant inside a formula; reference Assumptions. One consistent formula per line. $mm units, negatives in parentheses, leverage multiples as 0.0x (`0.0"x"`), percentages to one decimal (`0.0%`). The equity plug must be a live formula, never a typed number, so the table re-balances when any input changes.

## Checks
- Sources = Uses: `=TotalSources-TotalUses` equals 0 (the equity plug guarantees this; the check confirms the plug formula is correct).
- Cumulative leverage within the stated maximum: `=MaxCumulativeLeverage<=Assumptions!MaxLeverageTurns`.
- Each tranche amount >= 0 (no negative plug; if the plug goes negative the deal is over-funded, flag it).
- Equity plug >= 0: `=SponsorEquity>=0`.
- Master PASS/FAIL flag via IF over the check rows.

## Recalculate and verify
the workbook writer may not evaluate every Excel formula immediately, so the plug and leverage cells are blank until recalculated. No circularity here unless financing fees are sized off total sources that include the plug; if so, set financing fees off debt tranches only (as above) to avoid a loop, and document that choice on the Cover. Recalculate with a supported spreadsheet calculation engine when available, then scan for `#REF!`, `#DIV/0!`, `#VALUE!`, `#NAME?`; fix in a loop until zero errors and Sources = Uses before delivering.

## Inputs to gather
Purchase equity value or entry EV, existing debt to refinance, transaction and financing fee rates, minimum cash, LTM EBITDA, leverage turns and rates by tranche, rollover equity percentage, and cash on hand.

## Example
Hypothetical: entry EV 600.0, existing debt 100.0, transaction fees 2.0% (12.0), financing fees 2.5%, minimum cash 10.0. EBITDA 60.0; term loan at 4.0x (240.0), bonds at 1.5x (90.0); rollover 30.0; cash on hand 20.0. Total Uses roughly 730.0; debt + rollover + cash = 380.0; sponsor equity plug roughly 350.0; Sources = Uses; net leverage near 5.3x.
