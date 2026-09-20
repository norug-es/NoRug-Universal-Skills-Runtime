---
name: value-creation-bridge
version: 1.0.0-chatgpt
domain: private-equity
portable: true
dependencies: [irr-moic-calculator]
triggers: ["value creation bridge", "returns attribution", "ebitda growth deleveraging"]
description: Builds an equity value creation bridge .xlsx with live formulas across separate inputs, bridge, chart, and checks tabs that decomposes deal value into EBITDA growth, multiple expansion or contraction, and debt paydown or free cash flow, then ties to MOIC and IRR. Use when someone asks why a deal made money, to attribute returns to operational versus financial drivers, or to build a value bridge waterfall chart.
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


# Value Creation Bridge

## When to use
Use when someone needs to decompose the change in equity value across a hold into EBITDA growth, multiple expansion or contraction, and deleveraging or free cash flow, and to see each effect tie back to MOIC and IRR. The default view is a waterfall from entry equity to exit equity. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling; it should produce a standalone workbook.

## What it builds
- Cover: title, color legend, named-range list.
- Inputs: entry and exit EBITDA, entry and exit multiple, entry and exit net debt, dates, dividends.
- Bridge: entry equity, the three or four effects, exit equity, and the tie to MOIC and IRR.
- Chart: a waterfall chart from entry to exit equity built on bridge helper columns.
- Checks: effects sum to the total equity change; tie-out tests.

## Build workflow
1. Create the workbook and the four tabs above.
2. On Inputs, enter all blue assumptions and define named ranges.
3. On Bridge, compute entry and exit equity, then each decomposition effect as a live formula.
4. Build the waterfall chart helper columns (base, decrease, increase) and insert a stacked bar chart.
5. Wire Checks to the sum-of-effects identity.
6. Apply number formats and the color convention.
7. Recalculate the workbook headless so all formulas compute.
8. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver.

## Tab-by-tab spec

### Cover
- Title, one-line purpose, build date.
- Color legend: blue = input, black = formula, green = cross-tab link.
- Named-range index: EBITDA_in, EBITDA_out, Mult_in, Mult_out, ND_in, ND_out, Div and their cells.
- Optional scenario toggle (Base / Upside / Downside) that swaps the exit assumption block.

### Inputs (all blue)
- B2 Entry EBITDA, B3 Exit EBITDA.
- B4 Entry Multiple (EV/EBITDA), B5 Exit Multiple.
- B6 Entry Net Debt, B7 Exit Net Debt.
- B8 Entry Date, B9 Exit Date.
- B10 Cumulative Dividends paid to equity during hold (default 0).
- Define named ranges: EBITDA_in, EBITDA_out, Mult_in, Mult_out, ND_in, ND_out, Div.

### Bridge
- Entry EV: `=EBITDA_in*Mult_in`.
- Entry Equity: `=EBITDA_in*Mult_in - ND_in`.
- Exit EV: `=EBITDA_out*Mult_out`.
- Exit Equity: `=EBITDA_out*Mult_out - ND_out`.
- Effect 1 EBITDA growth: `=(EBITDA_out - EBITDA_in)*Mult_in`.
- Effect 2 Multiple expansion/(contraction): `=(Mult_out - Mult_in)*EBITDA_out`.
- Effect 3 Deleveraging/(FCF): `=ND_in - ND_out`.
- Effect 4 Dividends (optional separate bar): `=Div`.
- Reconstructed Exit Equity: `=Entry_Equity + Effect1 + Effect2 + Effect3 + Effect4`.
- MOIC: `=(Exit_Equity + Div)/Entry_Equity` formatted 0.0x.
- IRR: `=XIRR({-Entry_Equity, Div, Exit_Equity}, {Entry_Date, mid-date, Exit_Date})` or `=(MOIC)^(1/Years)-1` where Years `=(B9-B8)/365`.
- Note the cross-attribution choice: EBITDA effect uses entry multiple, multiple effect uses exit EBITDA, so the two interaction terms are absorbed consistently and the effects sum exactly.

### Chart
- Helper columns per bridge step: Label, Base (invisible floating offset), Value (visible bar).
- Base for an increase `=running cumulative before step`; for a decrease `=cumulative after step`.
- Insert a stacked BarChart: series 1 Base with no fill, series 2 Value visible. First and last bars (Entry, Exit) sit on zero base as totals.
- Percent-of-gain column: each effect over total equity change, `=Effect_n/(Exit_Equity+Div-Entry_Equity)` formatted 0.0%, to read which lever drove returns.

### Workbook build notes
- Write each effect as a formula string referencing named ranges; never paste the arithmetic result.
- Build the waterfall as a stacked BarChart with an invisible base series (set the base series fill to none).
- Use `DefinedName` for the seven inputs so the bridge and chart helpers stay readable.

## Formula and formatting conventions
Blue font for inputs. Black for in-tab formulas. Green for cross-tab links (`Inputs!`). No hardcoded numbers inside formulas; use named ranges. One consistent formula per effect row. Dollars with thousands separators, multiples as 0.0x, percentages 0.0%, EBITDA multiples shown as 0.0x.

## Checks
- Effects reconcile: `=ROUND((Effect1+Effect2+Effect3+Effect4)-(Exit_Equity+Div-Entry_Equity),2)=0`.
- Reconstructed equity ties: `=ROUND(Reconstructed_Exit_Equity-(Exit_Equity+Div),2)=0`.
- MOIC sanity: `=MOIC>0`.
- Multiple effect sign matches multiple change: `=SIGN(Effect2)=SIGN(Mult_out-Mult_in)`.
- Percent-of-gain sums to 100%: `=ROUND(SUM(percent column)-1,4)=0`.
- Entry equity positive: `=Entry_Equity>0` (guards the MOIC divisor).
- Deleveraging sign matches debt change: `=SIGN(Effect3)=SIGN(ND_in-ND_out)`.

## Recalculate and verify
After writing, recompute headless so XIRR, the effects, and the chart helper math resolve. Scan all cells for #REF!, #DIV/0!, #VALUE!, #NAME?. A common failure is the IRR exponent dividing by zero when entry and exit dates match; guard Years and fix. Recalc until clean, then deliver.

## Attribution variants to know
- The default cross-attribution (EBITDA effect on entry multiple, multiple effect on exit EBITDA) puts both interaction terms into the multiple effect. State this so the reader knows where the cross term sits.
- An alternative splits the interaction term evenly: EBITDA effect `=(EBITDA_out-EBITDA_in)*(Mult_in+Mult_out)/2`, multiple effect `=(Mult_out-Mult_in)*(EBITDA_in+EBITDA_out)/2`. Offer this as a toggle on Inputs if the user prefers a symmetric split; the effects still sum exactly.

## Inputs to gather
Entry and exit EBITDA, entry and exit EV/EBITDA multiples, entry and exit net debt, entry and exit dates, and any dividends paid to equity during the hold.

## Example
Hypothetical: entry EBITDA 50 at 8.0x with net debt 200 gives entry equity 200. Exit EBITDA 75 at 9.0x with net debt 120 gives exit equity 555. EBITDA growth effect `=(75-50)*8.0=200`, multiple effect `=(9.0-8.0)*75=75`, deleveraging `=200-120=80`; they sum to 355, the equity gain. MOIC about 2.8x.
