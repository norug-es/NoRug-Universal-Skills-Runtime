---
name: credit-stats-covenant
version: 1.0.0-chatgpt
domain: credit
portable: true
dependencies: [debt-schedule]
triggers: ["credit stats", "covenant", "leverage headroom"]
description: Builds a credit statistics and covenant headroom .xlsx from scratch with live formulas across separate inputs/calculations/outputs tabs plus checks, computing leverage, coverage, and liquidity ratios across the projection with per-period covenant PASS/FAIL flags and headroom. Use when someone wants a downloadable credit and covenant tracker.
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


# Credit Stats and Covenant

## When to use
Use when the user wants a new credit profile and covenant compliance schedule: leverage, coverage, and liquidity ratios computed each period off a projection, tested against maximum-leverage and minimum-coverage covenants, with headroom and a PASS/FAIL flag per period. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling. It should produce a standalone workbook without requiring an Excel add-in.

## What it builds
Tabs: Cover (legend), Assumptions (blue inputs: EBITDA, capex, interest, debt balances, cash, revolver commitment, covenant levels), Credit Stats (ratio schedule), Covenants (tests, headroom, flags), Checks. Inputs live only on Assumptions. If the user has a separate operating/debt model, link the input rows to it; otherwise drive from Assumptions.

## Build workflow
1. Create the five tabs; periods across columns.
2. On Assumptions, lay out per-period EBITDA, capex, cash interest, total debt, senior debt, cash, revolver commitment and drawn amount, plus the covenant levels (maximum leverage, minimum interest coverage, minimum fixed-charge coverage).
3. Build the Credit Stats schedule: leverage, coverage, and liquidity rows.
4. Build the Covenants tab: actual vs covenant, headroom, and a PASS/FAIL flag per period.
5. Add a tightest-period summary (minimum headroom across the projection).
6. Wire Checks; apply formatting and the cover legend.
7. Recalculate the workbook headless.
8. Verify zero formula errors and consistent ratio definitions, then deliver the .xlsx.

## Tab-by-tab spec
Periods across columns (D = first period). One consistent formula per row.

Credit Stats
- Total leverage: `=Assumptions!E_TotalDebt/Assumptions!E_EBITDA`.
- Net leverage: `=(Assumptions!E_TotalDebt-Assumptions!E_Cash)/Assumptions!E_EBITDA`.
- Senior leverage: `=Assumptions!E_SeniorDebt/Assumptions!E_EBITDA`.
- Interest coverage: `=Assumptions!E_EBITDA/Assumptions!E_CashInterest`.
- EBITDA-capex coverage: `=(Assumptions!E_EBITDA-Assumptions!E_Capex)/Assumptions!E_CashInterest`.
- Fixed-charge coverage (FCCR): `=(Assumptions!E_EBITDA-Assumptions!E_Capex)/(Assumptions!E_CashInterest+Assumptions!E_MandatoryDebtAmort)`.
- Liquidity: `=(Assumptions!E_RevolverCommitment-Assumptions!E_RevolverDrawn)+Assumptions!E_Cash`.
Keep one definition of EBITDA and one of interest used consistently across every ratio (do not mix gross and net interest between rows).

Covenants
- Max leverage test: actual `=CreditStats!E_TotalLeverage`; covenant `=Assumptions!E_MaxLeverageCov`; headroom `=Covenant-Actual` (positive = cushion); flag `=IF(Actual<=Covenant,"PASS","FAIL")`.
- Min interest coverage test: actual `=CreditStats!E_InterestCoverage`; covenant `=Assumptions!E_MinCoverageCov`; headroom `=Actual-Covenant`; flag `=IF(Actual>=Covenant,"PASS","FAIL")`.
- Min FCCR test: actual `=CreditStats!E_FCCR`; covenant `=Assumptions!E_MinFCCRCov`; headroom `=Actual-Covenant`; flag `=IF(Actual>=Covenant,"PASS","FAIL")`.
- Headroom %: for leverage `=Covenant/Actual-1`; for coverage `=Actual/Covenant-1`.
- Period flag: `=IF(COUNTIF(this period's flags,"FAIL")=0,"PASS","FAIL")`.

Summary
- Tightest leverage headroom: `=MIN(leverage headroom row)`; tightest coverage headroom: `=MIN(coverage headroom row)`; first breach period via MATCH on the flag row.

## Formula and formatting conventions
Blue = inputs (Assumptions/Cover only). Black = in-tab formulas. Green = cross-tab links. Never hardcode a constant inside a formula; reference Assumptions. One consistent formula per row across periods. Leverage and coverage shown as 0.0x (`0.0"x"`), headroom % to one decimal (`0.0%`), dollars in $mm with negatives in parentheses. Use conditional formatting to shade FAIL flags.

## Checks
- Ratios use consistent definitions across periods (same EBITDA and interest source every row); spot-check by recomputing one ratio independently as a tie.
- No divide-by-zero: guard interest and EBITDA denominators (`=IF(denominator=0,"n/m",ratio)`).
- Any breach is flagged: master flag `=IF(COUNTIF(all flags,"FAIL")=0,"PASS","FAIL")` and the summary names the first breach period.
- Net leverage <= total leverage every period (sanity tie): `=MIN(TotalLeverage-NetLeverage)>=0`.

## Recalculate and verify
the workbook writer may not evaluate every Excel formula immediately, so all ratio and flag cells are blank until recalculated. No structural circularity here, but if EBITDA, interest, or debt rows are linked to a live debt or operating model that itself carries an interest/cash loop, recalculate that model first (or use its beginning-balance toggle). Recalculate with a supported spreadsheet calculation engine when available, then scan for `#REF!`, `#DIV/0!`, `#VALUE!`, `#NAME?`; fix in a loop until zero errors and consistent definitions before delivering.

## Inputs to gather
Per-period EBITDA, capex, cash interest, mandatory debt amortization, total and senior debt balances, cash, revolver commitment and drawn amount, and the covenant levels (maximum leverage, minimum interest coverage, minimum FCCR) with their first test date.

## Example
Hypothetical: year 1 EBITDA 60.0, capex 8.0, cash interest 14.0, total debt 330.0, senior debt 240.0, cash 15.0, revolver 50.0 undrawn. Total leverage 5.5x, net leverage 5.3x, interest coverage 4.3x, FCCR roughly 2.8x, liquidity 65.0. Covenant max leverage 6.5x gives 1.0x headroom (PASS); min coverage 2.5x gives comfortable cushion (PASS).
