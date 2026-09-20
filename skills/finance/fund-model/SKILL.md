---
name: fund-model
version: 1.0.0-chatgpt
domain: private-equity
portable: true
dependencies: [irr-moic-calculator, pe-returns-waterfall]
triggers: ["fund model", "private equity fund", "fund returns"]
description: Builds a PE fund-level J-curve .xlsx with live formulas across separate assumptions, calls and distributions, NAV, metrics, and checks tabs covering capital calls, management fees, portfolio growth, and distributions, with DPI, RVPI, TVPI, and net IRR. Use when someone asks to model a fund's cash flows to LPs, the J-curve, paid-in versus distributions, or fund-level return multiples.
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


# Fund Model (J-Curve)

## When to use
Use when someone needs a fund-level model that draws capital against commitments, charges management fees, grows portfolio value, distributes proceeds, and produces the net cash flow to LPs that creates the J-curve. The default outputs are DPI, RVPI, TVPI, and net IRR. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling; it should produce a standalone workbook.

## What it builds
- Cover: title, color legend, named-range list.
- Assumptions: commitment, investment period, fee rate and basis, growth, distribution pacing.
- Calls & Distributions: per-period calls, fees, distributions, and net LP cash flow.
- NAV: portfolio value roll-forward producing period-end NAV.
- Metrics: DPI, RVPI, TVPI, paid-in, and net IRR via XIRR on dated LP flows.
- Checks: cumulative calls within commitment, TVPI identity, uncalled non-negative.

## Build workflow
1. Create the workbook and the six tabs above.
2. On Assumptions, enter blue inputs and define named ranges.
3. Build Calls & Distributions period rows with live pacing formulas.
4. Build the NAV roll-forward linking calls in and distributions out.
5. Compute Metrics including XIRR on the dated net LP cash flow stream.
6. Wire Checks to TRUE/FALSE tests.
7. Apply number formats and the color convention.
8. Recalculate the workbook headless so all formulas compute.
9. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver.

## Tab-by-tab spec

### Cover
- Title, one-line purpose, build date.
- Color legend: blue = input, black = formula, green = cross-tab link.
- Named-range index: Commitment, FeeRate, Growth, InvPeriod, FundLife and their cells.
- Period basis toggle (annual or quarterly) wired by data validation; pacing formulas scale to it.

### Assumptions (all blue)
- B2 Commitment, B3 Investment period (years), B4 Fund life (years).
- B5 Mgmt fee rate, B6 Fee basis toggle ("Committed" then "Invested"), B7 Fee step-down year.
- B8 Annual portfolio growth rate, B9 Call pacing % per period, B10 Distribution pacing % per period.
- Named ranges: Commitment, FeeRate, Growth, InvPeriod, FundLife.

### Calls & Distributions
One row per period (year or quarter), column A Date.
- Capital called: `=MIN(Commitment*CallPace, Commitment - PriorCumCalls)` so cumulative calls never exceed commitment.
- Cumulative called: `=SUM($Calls$start:Calls_row)`.
- Management fee: `=IF(Year<=FeeStepDown, FeeRate*Commitment, FeeRate*InvestedCapital)` per the basis toggle.
- Distributions: link from NAV realizations, `=NAV!realized_row`.
- Net LP cash flow: `=-(CapitalCalled) - Fee + Distribution` (calls and fees out, distributions in). This stream dips negative early (the J-curve) then turns positive.

### NAV
- Opening NAV: `=PriorClosingNAV`.
- Plus invested this period: `=CallsAndDist!Called - CallsAndDist!Fee` (net of fee drag).
- Plus value growth: `=OpeningNAV*Growth`.
- Less distributions (realizations): `=-Distribution`.
- Closing NAV: `=Opening + Invested + Growth - Distributions`.
- Final-period NAV represents residual unrealized value used in RVPI.

### Metrics
- Paid-in (PIC): `=SUM(CapitalCalled) + SUM(Fees)` or calls-only per chosen convention; state the basis.
- DPI: `=SUM(Distributions)/PaidIn` formatted 0.0x.
- RVPI: `=EndingNAV/PaidIn` formatted 0.0x.
- TVPI: `=DPI + RVPI`.
- Net IRR: `=XIRR(net LP cash flow column with final NAV added as a terminal inflow, dates)`.
- Uncalled commitment: `=Commitment - CumCalls`.
- J-curve trough: `=MIN(CumNetCashFlow column)` and the period it occurs via `=INDEX(Date,MATCH(trough,CumNetCashFlow,0))`, so the deepest drawdown is reported.

### Workbook build notes
- Write the roll-forward and pacing as formula strings; never paste period balances.
- Include the terminal NAV as a final dated inflow row feeding XIRR so the net IRR is complete.
- Use `DefinedName` for Commitment, FeeRate, Growth so per-period formulas read by name and fill down cleanly.

## Formula and formatting conventions
Blue font for inputs (Assumptions). Black for in-tab formulas. Green for cross-tab links (`Assumptions!`, `NAV!`, `CallsAndDist!`). No hardcoded numbers inside formulas; use named ranges. One consistent formula per row, filled down the periods. Percentages 0.0%, dollars with separators, multiples 0.0x.

## Checks
- Cumulative calls within commitment: `=MAX(CumCalls column)<=Commitment`.
- TVPI identity: `=ROUND(TVPI-(DPI+RVPI),4)=0`.
- Uncalled non-negative: `=MIN(Uncalled column)>=0`.
- NAV non-negative at all periods: `=MIN(ClosingNAV column)>=0`.
- Net IRR below a gross IRR computed on the same flows without fees: `=NetIRR<=GrossIRR`.
- DPI and RVPI non-negative: `=AND(DPI>=0, RVPI>=0)`.

## Recalculate and verify
After writing, recompute headless so the roll-forward and XIRR resolve. Scan all cells for #REF!, #DIV/0!, #VALUE!, #NAME?. A common failure is XIRR not converging when the cash flow stream lacks a positive value before the terminal NAV; supply a guess and confirm the terminal NAV inflow is included. Recalc until clean, then deliver.

## Inputs to gather
Total commitment, investment period and fund life, management fee rate and basis with step-down timing, call and distribution pacing, and portfolio growth rate.

## Example
Hypothetical: 100 commitment, 5-year investment period, 2% fee on committed then invested, 12% portfolio growth, calls 20% per year, distributions starting year 4. Net LP cash flow is negative in years 1-3 (the J-curve trough), turns positive as realizations arrive. End metrics might show DPI 1.4x, RVPI 0.6x, TVPI 2.0x, with a net IRR in the mid-teens.
