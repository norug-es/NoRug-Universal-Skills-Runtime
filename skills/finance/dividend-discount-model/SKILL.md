---
name: dividend-discount-model
version: 1.0.0-chatgpt
domain: valuation
portable: true
dependencies: [scenario-manager, sensitivity-tables]
triggers: ["dividend discount", "ddm", "gordon growth dividend"]
description: Builds a dividend discount model .xlsx from scratch with live formulas across separate assumptions, DDM, sensitivity, and checks tabs. Use when a user wants to value a dividend-paying company (often a bank or insurer) by discounting forecast dividends at the cost of equity with a Gordon terminal value.
---
# Dividend Discount Model (DDM)

## ChatGPT execution contract

- **Runtime:** Treat this file as domain methodology and an execution contract, not as a dependency on a specific model vendor.
- **Workbook engine:** When creating or editing `.xlsx`, use the spreadsheet tooling available in the current ChatGPT environment. Follow the environment's native spreadsheet skill/instructions first.
- **No false verification:** Never claim formulas were recalculated, charts rendered, or checks passed unless the runtime actually verified them. If calculation support is unavailable, perform structural validation and state that Excel/Google Sheets must refresh cached formula values.
- **Inputs vs formulas:** Keep user-editable assumptions separate from derived calculations. Never embed avoidable magic numbers inside formulas.
- **Finance formatting:** Default to blue hardcodes, black same-sheet formulas, green cross-sheet links, red external-file links, yellow attention assumptions; format zeros as `-`, negatives red and in parentheses, multiples as `0.0x`, and always state units.
- **Source provenance:** For researched financial inputs, prefer primary sources and place source URLs in cell comments (or a dedicated source field where comments are unavailable).
- **QA gate:** Scan key ranges for broken references and formula errors; verify model-specific tie-outs; inspect important output ranges; validate visual layout before export.
- **Preservation rule:** If editing an existing workbook, preserve its structure and style unless the user explicitly requests a rebuild or redesign.


## When to use
Use when the user wants to value the equity of a dividend payer directly off its dividend stream, which suits banks, insurers, utilities, and other stable payers where free cash flow is hard to define. Supports a multi-stage explicit forecast plus a Gordon terminal, and a single-stage Gordon variant. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling, without requiring an Excel add-in or plugin. Trigger on DDM, dividend discount, Gordon growth, cost of equity valuation, or dividend-based valuation.

## What it builds
A workbook with these tabs:
- Cover: purpose, key assumptions snapshot, color legend, valuation date.
- Assumptions: cost of equity drivers, dividend growth path, payout, terminal growth, scenario toggle (blue inputs).
- DDM: explicit dividend forecast, discount factors, PV of dividends, terminal value, and value per share; plus a single-stage Gordon block.
- Sensitivity: native two-variable Data Table, cost of equity by terminal growth.
- Checks: tie-outs and sanity flags.

## Build workflow
1. Create the four tabs in order and freeze header rows.
2. On Assumptions, lay out every driver as its own labeled blue input cell and name the major ones (Ke, TermGrowth, Scenario).
3. Build a scenario block (Base, Bull, Bear) and select live values with CHOOSE(Scenario, ...).
4. On DDM, build cost of equity via CAPM and forecast dividends per share across the explicit years.
5. Discount each dividend, sum the PVs, build the Gordon terminal value and its PV, and total to value per share.
6. Add the single-stage Gordon variant as a separate small block for cross-check.
7. On Sensitivity, build the Ke by terminal growth Data Table feeding value per share.
8. On Checks, add the Ke greater than g and payout sanity flags.
9. Recalculate with a supported spreadsheet calculation engine when available; otherwise validate formulas structurally and disclose that cached values require recalculation in Excel/Google Sheets.
10. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver the .xlsx.

## Tab-by-tab spec
Assumptions tab. One column per scenario plus a live column chosen by CHOOSE. Rows (blue inputs): Latest dividend per share (year 0), EPS year 0, Payout ratio, Dividend growth % per explicit year, Risk free rate, Equity risk premium, Beta, Terminal growth g, Explicit horizon (years), Scenario selector. Live driver example: `=CHOOSE($B$Scenario, C5, D5, E5)`.

DDM tab.
- Cost of equity (CAPM): `=RiskFree+Beta*ERP` (name it Ke).
- Explicit dividend per share each year: `=PriorDPS*(1+DividendGrowth)`, or derive from EPS and payout: `=EPS_t*PayoutRatio` with EPS grown each year.
- Period t: 1, 2, ... N.
- Discount factor: `=1/(1+Ke)^t`.
- PV of dividend: `=DPS_t*DiscountFactor_t`; sum: `=SUM(PVrow)`.
- Terminal value (Gordon on the year-N dividend): `=DPS_N*(1+TermGrowth)/(Ke-TermGrowth)`.
- PV of terminal value: `=TerminalValue*DiscountFactor_N`.
- Value per share (multi-stage): `=SumPV_Dividends+PV_TerminalValue`.
- Single-stage Gordon variant (separate block): `=DPS_0*(1+TermGrowth)/(Ke-TermGrowth)` for a quick cross-check.

Sensitivity tab. Put the multi-stage value per share formula in the corner cell, Ke values down the left column, terminal growth across the top row, then build a native two-variable Data Table with row input = TermGrowth cell and column input = Ke cell.

## Formula and formatting conventions
Blue font for input cells, black for formulas, green for links to other tabs. Never hardcode a number inside a formula; every assumption is its own labeled input cell on Assumptions. Use one consistent formula across the dividend forecast row. Number formats: per share values as `#,##0.00`, discount factors as `0.000`, percentages and growth and payout to one decimal as `0.0%`. Name major drivers (Ke, TermGrowth, Payout, Scenario) for readable cross-tab links.

## Checks
- Ke greater than g: flag if `Ke<=TermGrowth` (Gordon denominator breaks or goes negative).
- Payout ratio sane: flag if payout is below 0% or above 100% in any year (input bounds).
- Dividend growth below Ke in the explicit window so PVs stay finite and sensible.
- Single-stage versus multi-stage value within a sane band; flag large divergence as an assumption inconsistency.
- Implied terminal share of value: `=PV_TerminalValue/ValuePerShare`; flag if dominated by the terminal.

## Recalculate and verify
Always write live formulas, never paste computed numbers. After writing, recalculate the workbook headlessly so cached values populate, then scan all cells for #REF!, #DIV/0!, #VALUE!, and #NAME?. Watch the Gordon denominator `Ke-TermGrowth` for zero or negative values. Fix and recalculate in a loop until zero errors, then deliver the .xlsx.

## Inputs to gather
Valuation date, latest dividend per share or EPS and payout ratio, dividend growth path, explicit horizon, risk free rate, equity risk premium, beta, terminal growth, and the scenario assumptions if running Base, Bull, and Bear.

## Example
Hypothetical: latest dividend per share 2.00, growing 8.0% for five explicit years then 3.0% in perpetuity, risk free 4.0%, ERP 5.0%, beta 0.90, giving Ke near 8.5%. The explicit PVs plus the PV of the Gordon terminal produce an illustrative value per share; the single-stage Gordon on the current dividend gives a rough cross-check. All numbers are made up for illustration.
