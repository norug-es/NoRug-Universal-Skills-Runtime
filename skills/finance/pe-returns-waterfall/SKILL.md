---
name: pe-returns-waterfall
version: 1.0.0-chatgpt
domain: private-equity
portable: true
dependencies: [irr-moic-calculator]
triggers: ["returns waterfall", "carried interest", "distribution waterfall"]
description: Builds an LP/GP distribution waterfall .xlsx with live formulas across separate inputs, cash flow, waterfall, summary, and checks tabs, defaulting to a European whole-fund structure with an American toggle, four ordered tiers, and per-tier LP/GP splits. Use when someone asks to model carried interest, a preferred return hurdle, GP catch-up, or how fund profits split between limited and general partners.
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


# PE Returns Waterfall

## When to use
Use when someone needs a distribution waterfall that splits fund or deal proceeds between LPs and the GP through return of capital, a preferred return, a GP catch-up, and a carried interest split. Default to a European (whole-fund) waterfall with a toggle to American (deal-by-deal) timing. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling; it should produce a standalone workbook.

## What it builds
- Cover: title, color legend, scenario toggle cell, named-range list.
- Assumptions: hurdle rate, carry %, catch-up split, GP commitment %, waterfall type toggle.
- Cash Flows: dated LP contributions and gross distributions by period.
- Waterfall: the four tiers computed in order with LP and GP dollars, cumulative columns.
- Summary: LP gross vs net IRR and MOIC, GP carry dollars, realized carry %.
- Checks: tier sums, LP plus GP reconciliation, realized carry test.

## Build workflow
1. Create the workbook and the six tabs in the order above.
2. On Assumptions, define named ranges: Hurdle, Carry, CatchUpGPShare, WaterfallType.
3. Enter dated cash flows on Cash Flows as blue inputs; compute cumulative contributed capital.
4. Build the Waterfall tiers as live formulas that cascade remaining distributable cash.
5. Compute Summary metrics with XIRR on the dated net LP cash flows.
6. Wire the Checks tab to TRUE/FALSE tests.
7. Apply number formats and the color convention.
8. Recalculate with a supported spreadsheet calculation engine when available; otherwise perform structural formula validation and mark recalculation as not verified.
9. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver.

## Tab-by-tab spec

### Cover
- Title, one-line purpose, build date.
- Color legend: blue = input, black = formula, green = cross-tab link.
- Named-range index: Hurdle, Carry, CatchUpGPShare, WaterfallType and their cells.
- The WaterfallType toggle ("European" / "American") lives here or mirrors Assumptions; data validation drives it.

### Assumptions
- B2 Hurdle (e.g. 0.08), B3 Carry (0.20), B4 CatchUpGPShare (1.00 for full catch-up, or 0.20 for 80/20), B5 GP commitment %.
- B6 WaterfallType as a data-validation list: "European" or "American". All four are inputs (blue).

### Cash Flows
- Column A Date, B LP Contribution (negative to LP), C Gross Distribution (positive).
- D Cumulative Contributions: `=SUM($B$4:B4)` magnitude tracked as positive `=-SUM($B$4:B4)`.
- E Cumulative Distributions: `=SUM($C$4:C4)`.

### Waterfall
One row per distribution period. For each period compute remaining cash, then cascade.
- Distributable this period: link to Cash Flows gross distribution, `=CashFlows!C4`.
- Tier 1 Return of Capital to LP: `=MIN(Distributable, MAX(0, CumContrib - PriorRoC))`. 100% to LP until contributed capital returned.
- Tier 2 Preferred Return to LP: accrue hurdle on outstanding contributed capital. PrefAccrued `=OutstandingCapital*Hurdle*(Days/365)` using `(A5-A4)` for Days. Tier 2 LP `=MIN(RemainingAfterT1, MAX(0, CumPrefAccrued - PriorPrefPaid))`.
- Tier 3 GP Catch-Up: GP receives CatchUpGPShare of distributions until GP carry equals Carry of profits above return of capital. Target GP catch-up `=Carry/(1-Carry)*CumPrefPaid` (for full catch-up). Tier 3 GP `=MIN(RemainingAfterT2, MAX(0, TargetCatchUp - PriorGPCatchUp))`.
- Tier 4 Carry Split on residual: LP `=RemainingAfterT3*(1-Carry)`, GP `=RemainingAfterT3*Carry`.
- LP total per period `=T1 + T2 + T4_LP`; GP total `=T3 + T4_GP`. Add cumulative columns with running `=SUM`.
- American toggle: wrap tier logic in `=IF(WaterfallType="European", whole-fund formula, deal-level formula)` so American resets capital/pref per deal grouping column.

### Summary
- LP Contributed: `=-SUM(CashFlows!B:B)`; LP Distributed: `=SUM(Waterfall LP column)`.
- LP MOIC: `=LP_Distributed/LP_Contributed` formatted 0.0x.
- LP Net IRR: `=XIRR(net LP dated flows, dates)`; Gross IRR: `=XIRR(gross flows, dates)`.
- GP Carry $: `=SUM(Waterfall GP column) - GP_capital_returned`.
- Realized Carry %: `=GP_Carry / Total_Profit_Above_RoC`.
- Carry as a value-share: `=GP_Total/(LP_Total+GP_Total)` for a sanity read against the target carry.
- DPI for LPs: `=LP_Distributed/LP_Contributed` formatted 0.0x, shown alongside MOIC.

### Workbook build notes
- Write every tier as a live formula string; never paste a computed split.
- Use `DefinedName` for Hurdle, Carry, CatchUpGPShare, WaterfallType so tier formulas read by name.
- Preferred accrual needs dated periods: keep one row per distribution date and compute `(A_next - A_this)` day counts in-sheet.
- Apply a single fill-down formula per tier column so the cascade stays consistent.

## Formula and formatting conventions
Blue font for inputs (Assumptions, raw cash flows). Black for in-tab formulas. Green for cross-tab links (`CashFlows!`, `Assumptions!`). No hardcoded numbers inside formulas; reference named ranges instead. One consistent formula per row, filled across. Percentages as 0.0%, dollars with thousands separator, MOIC as 0.0x, multiples as 0.0x.

## Checks
- Tiers sum to total: `=ROUND(SUM(T1:T4)-TotalDistributions,2)=0`.
- LP plus GP equals total: `=ROUND(LP_Total+GP_Total-TotalDistributions,2)=0`.
- Realized carry matches target after full catch-up: `=ROUND(RealizedCarry%-Carry,4)=0` (only once catch-up complete).
- No negative tier values: `=MIN(all tier cells)>=0`.
- LP gets all of tier 1 and 2: `=AND(T1_GP=0, T2_GP=0)`.
- Catch-up does not overshoot target: `=CumGPCatchUp<=TargetCatchUp+0.01`.
- Net IRR below gross: `=LP_Net_IRR<=Gross_IRR`.

## Recalculate and verify
After writing, open the file headless and force a full recompute so XIRR and the cascade resolve. Scan every cell for #REF!, #DIV/0!, #VALUE!, #NAME?. If any appear, trace the broken reference (often a missing named range or a divide where contributed capital is zero), fix, recalc again, and repeat until clean.

## Inputs to gather
Fund or deal cash flows with dates, committed and contributed capital, hurdle rate, carry %, catch-up basis (full or 80/20), and whether the waterfall is European or American.

## Example
Hypothetical: LPs contribute 100 across year 0-2, gross distributions of 60, 80, 90 in years 3-5. Hurdle 8%, carry 20%, full catch-up. Tier 1 returns 100, Tier 2 pays the accrued 8% preferred, Tier 3 catches the GP up to 20% of profit, Tier 4 splits the rest 80/20. Summary shows LP net MOIC around 1.8x and a positive net IRR; GP carry roughly 20% of total profit above capital.
