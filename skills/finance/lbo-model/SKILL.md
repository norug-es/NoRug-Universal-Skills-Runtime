---
name: lbo-model
version: 1.0.0-chatgpt
domain: private-equity
portable: true
dependencies: [sources-and-uses, debt-schedule, irr-moic-calculator, scenario-manager, sensitivity-tables]
triggers: ["lbo", "leveraged buyout", "sponsor returns"]
description: Builds a leveraged buyout .xlsx from scratch with live formulas across separate inputs/calculations/outputs tabs plus checks, including sources and uses, a debt schedule with cash sweep, IRR and MOIC returns, and sensitivity data tables. Use when someone wants a downloadable sponsor returns model for a buyout.
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


# LBO Model

## When to use
Use when the user wants a new leveraged buyout model that sizes entry debt and equity, projects free cash flow, pays down debt with a cash sweep, and solves sponsor returns (IRR and MOIC) at exit, with sensitivity tables on entry/exit multiple and leverage. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling. It should produce a standalone workbook without requiring an Excel add-in.

## What it builds
Tabs: Cover (legend, scenario toggle, circuit-breaker toggle), Assumptions (blue inputs), Sources & Uses, Operating Model (EBITDA to free cash flow), Debt Schedule (tranches, mandatory amortization, cash sweep), Returns (IRR, MOIC, equity bridge), Sensitivity (two-variable data tables), Checks. Inputs live only on Assumptions.

## Build workflow
1. Create the eight tabs; years across columns with year 0 = entry.
2. On Assumptions, set entry EBITDA, entry multiple, exit multiple, fees, leverage by tranche, rates, amortization, cash sweep %, minimum cash, tax rate, and the hold period. Add scenario and circuit-breaker toggles; name key ranges.
3. Build Sources & Uses: entry EV = entry EBITDA x entry multiple; uses = EV + fees + refinanced debt; sources = debt tranches + sponsor equity (the plug).
4. Build the Operating Model: project EBITDA, less cash taxes, less capex, less change in NWC, less cash interest = free cash flow before debt paydown.
5. Build the Debt Schedule: per tranche beginning balance, mandatory amortization, optional sweep prepayment, ending balance, and interest.
6. Build the equity bridge and Returns: exit EV = exit EBITDA x exit multiple; equity value = exit EV - net debt; IRR and MOIC on sponsor cash flows.
7. Build two Sensitivity data tables (entry x exit multiple to IRR; leverage to IRR).
8. Wire Checks; apply formatting and the cover legend.
9. Recalculate the workbook headless.
10. Verify zero formula errors and that Sources = Uses, then deliver the .xlsx.

## Tab-by-tab spec
Year 0 = entry; projection years follow. One consistent formula per row.

Sources & Uses
- Entry EV: `=Assumptions!EntryEBITDA*Assumptions!EntryMultiple`.
- Uses: purchase EV, transaction fees `=EntryEV*Assumptions!FeePct`, refinanced existing debt, minimum cash. Total uses = sum.
- Sources: each debt tranche `=Assumptions!EntryEBITDA*Assumptions!Tranche_x_Turns`, then sponsor equity plug `=TotalUses-SumOfDebt-RolloverEquity`. Total sources = sum.

Operating Model
- Revenue and EBITDA projected from Assumptions growth/margin. EBITDA: `=E_Revenue*Assumptions!E_EBITDAMargin`.
- Cash taxes: `=-MAX(0,(EBITDA-DA-Interest))*Assumptions!TaxRate`. Capex: `=-E_Revenue*Assumptions!CapexPct`.
- Change in NWC from days. Free cash flow before paydown: `=EBITDA+CashTaxes+Capex-NWCChange-MandatoryAmort` with cash interest linked from Debt Schedule.
- Cash available for sweep: `=FCF-MinCashTopUp`.

Debt Schedule (per tranche, senior to junior)
- Beginning: prior ending (`=D_Ending`). Mandatory amortization: `=-MIN(Beginning, Assumptions!Tranche_AmortPct*OriginalFace)`.
- Sweep prepayment: `=-MIN(Beginning+MandatoryAmort, MAX(0, CashForSweep_Remaining))*Assumptions!SweepPct`.
- Ending: `=Beginning+MandatoryAmort+Sweep`. Interest: `=Assumptions!Tranche_Rate*IF(Circuit_Breaker=1, Beginning, AVERAGE(Beginning,Ending))`.
- Revolver absorbs any cash shortfall to hold minimum cash; cash sweep cascades remaining cash down the waterfall by seniority.

Returns
- Exit EV: `=ExitEBITDA*Assumptions!ExitMultiple`. Net debt at exit: `=SumEndingDebt-EndingCash`.
- Equity value at exit: `=ExitEV-NetDebt`. Sponsor cash flows: year 0 `=-SponsorEquity`, exit year `=ExitEquity`.
- MOIC: `=ExitEquity/SponsorEquity`. IRR: `=IRR(CashFlowRow)` or `=XIRR(values,dates)` if dated.

Sensitivity
- Two-variable Data Tables: row input = exit multiple, column input = entry multiple, result cell `=Returns!IRR`. Second table leverage (turns) to IRR. Build with Excel data-table structure (TABLE array) or write the grid as repeated IRR formulas keyed off scenario inputs.

## Formula and formatting conventions
Blue = inputs (Assumptions/Cover only). Black = in-tab formulas. Green = cross-tab links. Never hardcode a constant inside a formula; reference Assumptions. One identical formula per row across years. $mm units, negatives in parentheses, multiples 0.0x, percentages and IRR to one decimal. Formats: `#,##0;(#,##0)`, `0.0"x"`, `0.0%`.

## Checks
- Sources = Uses: `=Sources!TotalSources-Sources!TotalUses` equals 0.
- Ending debt never negative on any tranche/year: `=MIN(all ending balances)>=0`.
- Minimum cash respected each period: `=MIN(EndingCash-MinCash)>=0`.
- Revolver within commitment. Master flag PASS/FAIL via IF over the check rows.

## Recalculate and verify
the workbook writer may not evaluate every Excel formula immediately, so values are blank until recalculated; circular interest needs the circuit-breaker before first calc. Recalculate with a supported spreadsheet calculation engine when available with iterative calculation enabled if averaging balances; document whether the model uses beginning balances (toggle = 1, no circularity) or average balances (toggle = 0, iterative). Scan for `#REF!`, `#DIV/0!`, `#VALUE!`, `#NAME?`; fix in a loop until zero errors and Sources = Uses before delivering.

## Inputs to gather
Entry EBITDA and entry multiple, fees, opening leverage by tranche with rates and amortization, cash sweep %, minimum cash, revenue/margin projection drivers, tax, capex, NWC days, hold period, and exit multiple.

## Example
Hypothetical: entry EBITDA 50.0 at 10.0x = EV 500.0; fees 15.0; debt 300.0 (term loan 250.0, revolver undrawn, bonds 50.0); sponsor equity plug 215.0. EBITDA grows to 70.0 by year 5; sweep repays term loan; exit at 10.0x = 700.0 less net debt 120.0 = equity 580.0. MOIC roughly 2.7x, IRR roughly 22.0%.
