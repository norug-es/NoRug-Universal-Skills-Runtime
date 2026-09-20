---
name: debt-schedule
version: 1.0.0-chatgpt
domain: credit
portable: true
dependencies: []
triggers: ["debt schedule", "debt paydown", "interest schedule"]
description: Builds a standalone debt and interest schedule .xlsx from scratch with live formulas across separate inputs/calculations/outputs tabs plus checks, modeling multiple tranches with mandatory amortization, a cash sweep waterfall by seniority, and interest. Use when someone wants a downloadable debt paydown schedule.
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


# Debt Schedule

## When to use
Use when the user wants a new standalone debt and interest schedule: several tranches (revolver, term loan A, term loan B, bonds) each rolling forward with beginning balance, mandatory amortization, an optional cash sweep prepayment, ending balance, and interest, where free cash flow available for paydown waterfalls down by seniority. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling. It should produce a standalone workbook without requiring an Excel add-in.

## What it builds
Tabs: Cover (legend, circuit-breaker toggle), Assumptions (blue inputs: opening balances, rates, amortization schedules, sweep %, free cash flow before debt), Debt Schedule (per-tranche rollforwards plus the cash sweep waterfall), Checks. Inputs live only on Assumptions.

## Build workflow
1. Create the four tabs; years/periods across columns.
2. On Assumptions, lay out each tranche's opening balance, original face, interest rate, mandatory amortization % or amount per period, revolver commitment, sweep % of available cash, minimum cash, and the free cash flow before debt paydown row. Add the circuit-breaker toggle; name key ranges.
3. Build the cash-available block: free cash flow before debt, less mandatory amortization, gives cash available for the sweep.
4. Build each tranche rollforward top of waterfall (most senior) first.
5. Cascade remaining sweep cash to the next tranche; revolver draws to cover any shortfall.
6. Compute interest per tranche on beginning or average balance per the toggle; total interest.
7. Wire Checks; apply formatting and the cover legend.
8. Recalculate the workbook headless.
9. Verify zero formula errors and tranche balances within limits, then deliver the .xlsx.

## Tab-by-tab spec
Periods across columns (D = first projection period). One consistent formula per row.

Assumptions
- Per tranche: opening balance, rate %, mandatory amortization (% of original face or fixed amount), original face, seniority rank. Revolver: commitment, rate, undrawn fee %.
- Sweep %, minimum cash, and a free cash flow before debt paydown input row.

Cash available block (Debt Schedule)
- Free cash flow before debt: `=Assumptions!E_FCFBeforeDebt`.
- Total mandatory amortization: `=SUM(tranche mandatory amort, this period)`.
- Cash available for sweep: `=MAX(0, FCFBeforeDebt - TotalMandatoryAmort - MinCashTopUp)`.

Per-tranche rollforward (repeat top to bottom of waterfall)
- Beginning: prior ending (`=D_Ending`), first period `=Assumptions!Tranche_Opening`.
- Mandatory amortization: `=-MIN(Beginning, Assumptions!Tranche_AmortPct*Assumptions!Tranche_OriginalFace)`.
- Sweep prepayment: `=-MIN(Beginning+MandatoryAmort, CashForSweep_RemainingForThisTranche)*Assumptions!SweepPct`.
- CashForSweep for the next (more junior) tranche: `=PriorTranche_CashForSweep - ABS(PriorTranche_Sweep)`.
- Ending: `=Beginning+MandatoryAmort+Sweep`.
- Interest: `=Assumptions!Tranche_Rate*IF(Circuit_Breaker=1, Beginning, AVERAGE(Beginning,Ending))`.

Revolver
- Draw to cover shortfall: `=MAX(0, MinCash - CashAfterTermPaydown)`; repay when surplus.
- Ending must stay within commitment: `=MIN(Commitment, Beginning+Draw-Repay)`.
- Total interest row: `=SUM(all tranche interest, this period)` plus revolver undrawn fee `=Assumptions!UndrawnFee*(Commitment-RevolverEnding)`.

## Formula and formatting conventions
Blue = inputs (Assumptions/Cover only). Black = in-tab formulas. Green = cross-tab links. Never hardcode a constant inside a formula; reference Assumptions. One identical formula per row across periods. $mm units, negatives in parentheses, rates and percentages to one decimal. Formats: `#,##0;(#,##0)`, `0.0%`.

## Checks
- Every tranche ending balance >= 0: `=MIN(all endings)>=0`.
- Revolver ending <= commitment each period: `=MAX(RevolverEnding-Commitment)<=0`.
- Total interest equals the sum of tranche interest (recompute independently as a tie).
- Sweep never exceeds cash available: `=MIN(CashForSweep - TotalSweepUsed)>=0`.
- Master PASS/FAIL flag via IF over the check rows.

## Recalculate and verify
the workbook writer may not evaluate every Excel formula immediately; the sweep and interest form a circular loop (interest reduces cash, cash drives the sweep, the sweep changes balances and thus interest). Set the circuit-breaker to 1 (interest on beginning balance) to break circularity for a clean first calc, or enable iterative calculation in a compatible spreadsheet engine if using average balances; document the choice on the Cover. Recalculate with a supported spreadsheet calculation engine when available, then scan for `#REF!`, `#DIV/0!`, `#VALUE!`, `#NAME?`; fix in a loop until zero errors and all balances within limits before delivering.

## Inputs to gather
Opening balance, rate, and amortization for each tranche; tranche seniority order; revolver commitment and undrawn fee; sweep percentage; minimum cash; and the free cash flow before debt paydown for each period.

## Example
Hypothetical: term loan A 100.0 at 5.0% amortizing 5.0% of face/year; term loan B 150.0 at 6.0%, no mandatory amortization, 50.0% sweep; revolver 50.0 commitment at 4.5%. Free cash flow before debt 40.0 in year 1; 5.0 mandatory amortization, 17.5 sweep to term loan A then term loan B; total interest roughly 13.5; all endings stay positive.
