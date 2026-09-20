---
name: three-statement-model
version: 1.0.0-chatgpt
domain: core-modeling
portable: true
dependencies: [revenue-build, debt-schedule, scenario-manager]
triggers: ["three statement", "3 statement", "integrated financial model"]
description: Builds an integrated three-statement (income statement, balance sheet, cash flow) .xlsx from scratch with live formulas across separate inputs/calculations/outputs tabs plus a balancing check. Use when someone wants a downloadable, fully linked operating model where cash, retained earnings, and debt flow between statements.
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


# Three-Statement Model

## When to use
Use when the user wants a brand new, integrated financial model where the income statement, balance sheet, and cash flow statement are linked by live formulas so a change in one assumption ripples through all three. Typical for company operating models, base/upside/downside cases, and any task that ends with "the balance sheet has to balance." This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling. It should produce a standalone workbook without requiring an Excel add-in.

## What it builds
A workbook with these tabs: Cover (title, scenario toggle, color legend), Assumptions (blue inputs), IS (income statement), BS (balance sheet), CF (cash flow, indirect method), Debt & Interest (rollforward and interest), Checks (tie-outs). Inputs live only on Assumptions; IS/BS/CF/Debt are calculation tabs that read from it.

## Build workflow
1. Create the seven tabs and freeze header rows; put years across columns (one historical, projection years following).
2. On Assumptions, lay out blue input cells for revenue growth, gross margin, opex, tax rate, D&A, capex, NWC days, dividend payout, opening debt, and interest rate. Add a scenario toggle (1/0 or a CHOOSE index) and name the key ranges.
3. Build IS top to bottom with one formula per row across years.
4. Build Debt & Interest: beginning debt, draws/repayments, ending debt, and interest on beginning (or average) balance.
5. Build CF (indirect) from net income plus non-cash items less NWC change less capex plus financing; carry ending cash.
6. Build BS: cash from CF ending cash, retained earnings roll, debt from Debt tab; total and balance.
7. Wire the Checks tab (balance sheet ties to zero, cash agrees, retained earnings agrees).
8. Apply formatting conventions and the cover legend.
9. Recalculate the workbook headless.
10. Verify zero formula errors, confirm the balance check is zero every period, and deliver the .xlsx.

## Tab-by-tab spec
Assume year columns start at D (D=historical, E onward = projection). Rows are illustrative; keep one consistent formula per row.

Assumptions
- Revenue growth %, gross margin %, opex % of revenue, tax rate %, D&A as % of revenue or of prior PP&E, capex as % of revenue, days sales outstanding, days inventory, days payable, dividend payout %, interest rate %, opening debt.
- Scenario: `Scenario_Toggle` named cell; growth row = `CHOOSE(Scenario_Toggle, Base, Upside, Downside)` pulling from three stored input columns.

IS (income statement)
- Revenue: `=D_Revenue*(1+Assumptions!E_GrowthPct)` (first projection year off historical revenue).
- COGS: `=-E_Revenue*(1-Assumptions!E_GrossMarginPct)`; Gross profit: `=E_Revenue+E_COGS`.
- Opex: `=-E_Revenue*Assumptions!E_OpexPct`; EBITDA: `=GrossProfit+Opex`.
- D&A: `=-Assumptions!E_DA`; EBIT: `=EBITDA+DA`.
- Interest expense: `='Debt & Interest'!E_Interest` (negative).
- Pretax income: `=EBIT+Interest`; Taxes: `=-MAX(0,PretaxIncome)*Assumptions!E_TaxRate`; Net income: `=PretaxIncome+Taxes`.

Debt & Interest
- Beginning debt: prior ending (`=D_EndingDebt`), first year `=Assumptions!OpeningDebt`.
- Draw/(repay): input or sweep link; Ending debt: `=BeginningDebt+Draw`.
- Interest: `=Assumptions!E_IntRate*IF(Circuit_Breaker=1, BeginningDebt, AVERAGE(BeginningDebt,EndingDebt))`.

CF (indirect)
- Net income: `=IS!E_NetIncome`. Add back D&A: `=-IS!E_DA` (D&A on IS is negative, so this adds it back).
- Change in NWC: `=-(E_NWC-D_NWC)` where NWC = receivables + inventory - payables computed from days on Assumptions.
- Capex: `=-Assumptions!E_Capex`. CFO+CFI subtotal then financing.
- Financing: net debt draw `='Debt & Interest'!E_Draw` less dividends `=-IS!E_NetIncome*Assumptions!E_PayoutPct`.
- Net change in cash; Ending cash: `=BeginningCash+NetChange`.

BS (balance sheet)
- Cash: `=CF!E_EndingCash`. Receivables/inventory/payables from days. PP&E: `=D_PPE+Assumptions!E_Capex-(-IS!E_DA)`.
- Debt: `='Debt & Interest'!E_EndingDebt`. Retained earnings: `=D_RE+IS!E_NetIncome-Dividends`.
- Total assets, total liabilities + equity, and Balance: `=TotalAssets-TotalLiabEquity`.

## Formula and formatting conventions
Blue font = hardcoded input cells (only on Assumptions and Cover). Black = formulas computed within a tab. Green = links pulling from another tab. Never bury a constant inside a formula; put it on Assumptions and reference it. Use one identical formula filled across all year columns in a row. Units in $mm, negatives in parentheses, multiples as 0.0x, percentages to one decimal. Number format examples: `#,##0;(#,##0)` and `0.0%`.

## Checks
- Balance: `=BS!TotalAssets-BS!TotalLiabEquity` equals 0 every period (the master tie-out).
- Cash on BS equals CF ending cash each year.
- Retained earnings change equals net income less dividends.
- Ending debt on BS equals Debt & Interest ending debt.
- Each check row should read 0 (or TRUE); the Checks tab shows a single PASS/FAIL master flag with `=IF(SUMPRODUCT(...)=0,"PASS","FAIL")`.

## Recalculate and verify
The workbook writer may not compute cached formula values immediately. Recalculate with a supported spreadsheet calculation engine when available; otherwise perform structural validation and state that cached values still require refresh in Excel/Google Sheets. Then scan all cells for `#REF!`, `#DIV/0!`, `#VALUE!`, `#NAME?`. Fix and re-run in a loop until zero errors and the balance check is 0 in every period before delivering.

## Inputs to gather
Historical revenue and a starting balance sheet, projection horizon, revenue growth and margin assumptions, tax rate, capex and D&A logic, working-capital days, dividend policy, and opening debt with its interest rate. Note whether interest should use beginning or average debt.

## Example
Hypothetical: historical revenue 100.0, growth 8.0%, gross margin 60.0%, opex 35.0% of revenue, tax 25.0%, capex 5.0% of revenue, D&A 4.0, opening debt 50.0 at 6.0%. Year 1 revenue 108.0, EBITDA 27.0, interest 3.0 on beginning debt, net income roughly 15.0; ending cash and retained earnings roll forward and Assets minus (Liabilities + Equity) reads 0.0.
