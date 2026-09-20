---
name: dcf-model
version: 1.0.0-chatgpt
domain: valuation
portable: true
dependencies: [revenue-build, scenario-manager, sensitivity-tables]
triggers: ["dcf", "intrinsic value", "wacc", "terminal value"]
description: Builds a discounted cash flow valuation .xlsx from scratch with live formulas across separate assumptions, projection, DCF, sensitivity, and checks tabs. Use when a user wants to value a company by projecting unlevered free cash flow and discounting at WACC, with both Gordon growth and exit multiple terminal value.
---
# Discounted Cash Flow (DCF) Model

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
Use when the user wants an intrinsic valuation of a company or asset by forecasting unlevered free cash flow and discounting it at a weighted average cost of capital. Good for strategy, IB, and PE work where you need enterprise value, equity value, and value per share. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling, without requiring an Excel add-in or plugin. Trigger when you hear DCF, intrinsic value, WACC, terminal value, or free cash flow projection.

## What it builds
A workbook with these tabs:
- Cover: purpose, key assumptions snapshot, color legend, valuation date.
- Assumptions: all blue input cells (revenue growth, margins, tax, capex, NWC, WACC drivers, terminal value drivers, scenario toggle).
- Model: revenue down to unlevered free cash flow, year by year.
- DCF: discount factors, PV of FCF, terminal value (two methods), enterprise to equity bridge, per share.
- Sensitivity: native two-variable Data Table, WACC by terminal growth.
- Checks: tie-outs and sanity flags.

## Build workflow
1. Create the six tabs in order and freeze header rows.
2. On Assumptions, lay out every driver as its own labeled blue input cell and name the major ones (Tax, WACC, TermGrowth, ExitMultiple, Scenario).
3. Build a scenario block (Base, Bull, Bear) and select live values with CHOOSE(Scenario, ...).
4. On Model, project revenue, EBIT, taxes, D&A, capex, and change in NWC across the forecast years.
5. Compute unlevered free cash flow each year as a single consistent row formula.
6. On DCF, build WACC, discount factors, PV of FCF, both terminal values, enterprise value, and the equity bridge.
7. On Sensitivity, build the WACC by terminal growth Data Table feeding the per share output.
8. On Checks, add the terminal share and implied growth tie-outs.
9. Recalculate with a supported spreadsheet calculation engine when available; otherwise validate formulas structurally and disclose that cached values require recalculation in Excel/Google Sheets.
10. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver the .xlsx.

## Tab-by-tab spec
Assumptions tab. One column per scenario plus a live column chosen by CHOOSE. Rows: Revenue (year 0 actual), Revenue growth % per year, EBIT margin %, Tax rate, D&A as % of revenue, Capex as % of revenue, NWC as % of revenue, Risk free rate, Equity risk premium, Levered beta, Pretax cost of debt, Debt weight, Equity weight, Terminal growth g, Exit EV/EBITDA multiple, Mid-year toggle (0 or 1), Net debt, Minority interest, Investments, Diluted shares. Live driver example: `=CHOOSE($B$Scenario, C5, D5, E5)`.

Model tab. Columns are forecast years 1..N. Rows and formulas:
- Revenue: `=PriorRevenue*(1+GrowthPct)`.
- EBIT: `=Revenue*EBITMarginPct`.
- Taxes on EBIT: `=-EBIT*TaxRate`.
- NOPAT: `=EBIT+Taxes`.
- D&A: `=Revenue*DAPct` (add back).
- Capex: `=-Revenue*CapexPct`.
- NWC level: `=Revenue*NWCPct`; Change in NWC: `=-(NWC_t-NWC_t-1)`.
- Unlevered FCF: `=NOPAT+DA+Capex+ChangeNWC` (capex and NWC already signed negative).

DCF tab.
- Cost of equity (CAPM): `=RiskFree+Beta*ERP`.
- After-tax cost of debt: `=PretaxKd*(1-TaxRate)`.
- WACC: `=EquityWeight*CostEquity+DebtWeight*AfterTaxKd` (name it WACC).
- Period t for each year: 1, 2, ... N; with mid-year option `=t-0.5*MidYearToggle`.
- Discount factor: `=1/(1+WACC)^PeriodT`.
- PV of FCF: `=FCF_t*DiscountFactor_t`; sum: `=SUM(PVrow)`.
- Terminal value Gordon: `=FCF_N*(1+TermGrowth)/(WACC-TermGrowth)`.
- Terminal value exit multiple: `=EBITDA_N*ExitMultiple` where `EBITDA_N=EBIT_N+DA_N`.
- PV of terminal value: `=TV*DiscountFactor_N` (use final period discount factor).
- Enterprise value: `=SumPV_FCF+PV_TV` (choose which TV via a toggle or show both EVs).
- Equity value: `=EV-NetDebt-MinorityInterest+Investments`.
- Value per share: `=EquityValue/DilutedShares`.

Sensitivity tab. Put the per share formula in the top-left corner cell of the table, WACC values down the left column, terminal growth across the top row, then build a native two-variable Data Table with row input = TermGrowth cell and column input = WACC cell.

## Formula and formatting conventions
Blue font for input cells, black for formulas, green for links to other tabs. Never hardcode a number inside a formula; every assumption is its own labeled input cell on Assumptions. Use one consistent formula across each projection row so it fills cleanly. Number formats: currency in $mm as `#,##0.0`, negatives in parentheses, multiples as `0.0"x"`, percentages to one decimal as `0.0%`, discount factors as `0.000`. Name major drivers (WACC, TermGrowth, Tax, Scenario) so cross-tab links read clearly.

## Checks
- Implied terminal growth from the exit multiple: solve so that `ExitMultiple*EBITDA_N = FCF_N*(1+g_impl)/(WACC-g_impl)`; show g_impl and flag if it is far from assumed g.
- Share of value in terminal: `=PV_TV/EnterpriseValue`; flag if above a high threshold input.
- WACC greater than terminal growth: flag if `WACC<=TermGrowth` (Gordon breaks).
- Equity bridge ties: EV less net debt and minorities plus investments equals equity value.
- Cross-check the two terminal methods produce EVs within a sane band; flag large gaps.

## Recalculate and verify
Always write live formulas, never paste computed numbers. After writing, recalculate the workbook headlessly so cached values populate, then scan all cells for #REF!, #DIV/0!, #VALUE!, and #NAME?. If any appear, fix the formula or missing input and recalculate again. Repeat until zero errors, then deliver the .xlsx.

## Inputs to gather
Valuation date, forecast horizon (years), latest revenue, revenue growth path, EBIT margin path, tax rate, D&A and capex as percent of revenue, NWC as percent of revenue, risk free rate, equity risk premium, beta, pretax cost of debt, capital weights, terminal growth, exit EV/EBITDA multiple, net debt, minorities, investments, diluted shares, mid-year convention preference.

## Example
Hypothetical: latest revenue 1,000.0 $mm, growth 8.0% fading to 3.0% over five years, EBIT margin 20.0%, tax 25.0%, D&A 5.0% and capex 6.0% of revenue, NWC 10.0% of revenue, risk free 4.0%, ERP 5.0%, beta 1.10, pretax Kd 6.0%, weights 70/30 equity/debt, terminal g 2.5%, exit 9.0x. WACC computes near 9.4%. Sum of PV of FCF plus PV of terminal value yields an illustrative enterprise value, and after subtracting net debt of 200.0 $mm over 100.0 shares gives a hypothetical value per share. All figures are made up for illustration.
