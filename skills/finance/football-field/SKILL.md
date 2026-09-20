---
name: football-field
version: 1.0.0-chatgpt
domain: valuation
portable: true
dependencies: [dcf-model, trading-comps, precedent-transactions, sum-of-the-parts]
triggers: ["football field", "valuation range chart"]
description: Builds a valuation football field summary .xlsx from scratch with live formulas and a floating bar range chart across separate methods, chart data, chart, and checks tabs. Use when a user wants to collect low and high implied values from several valuation methods and display them as a horizontal range chart with a current price reference.
---
# Football Field (Valuation Summary Range Chart)

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
Use when the user has run several valuation methods (DCF, trading comps, precedent transactions, 52-week range, LBO range, analyst targets) and wants a single chart showing each method's low-to-high range side by side with the current price. The classic IB and PE summary exhibit. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling, without requiring an Excel add-in or plugin. Trigger on football field, valuation summary chart, valuation range chart, or value-per-share ranges.

## What it builds
A workbook with these tabs:
- Cover: purpose, method list, color legend, valuation date, current price.
- Methods: low and high implied value per share (or EV) for each method (blue inputs or green links).
- Chart Data: the helper table that makes the floating bar work (invisible base plus visible range).
- Chart: the floating horizontal bar chart with a current price reference.
- Checks: range and labeling flags.

## Build workflow
1. Create the four tabs and freeze header rows.
2. On Methods, list each valuation method with its low and high value as blue inputs or green links from other models.
3. On Chart Data, build the floating-bar helper: a Base column equal to the low, and a Range column equal to high minus low.
4. Add a current price input and a midpoint column for labeling.
5. On Chart, build a horizontal stacked bar chart from Base then Range using the runtime’s spreadsheet chart API; make the Base series invisible.
6. Add the current price as a reference (a separate single-point series or a labeled marker line).
7. Set the category axis to the method names and the value axis number format to currency.
8. On Checks, confirm every low is at or below its high and all methods are labeled.
9. Recalculate with a supported spreadsheet calculation engine when available; otherwise validate formulas structurally and disclose that cached values require recalculation in Excel/Google Sheets.
10. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver the .xlsx.

## Tab-by-tab spec
Methods tab. One row per method. Columns: Method label (e.g. DCF, Trading Comps, Precedent Transactions, 52-Week Range, LBO, Analyst Targets), Low value, High value. Low and high are blue inputs or green links to the DCF, comps, and precedent transaction outputs. Add a single Current price input cell.

Chart Data tab. One row per method, linking to Methods (green links). Columns and formulas:
- Base (invisible segment): `=MethodLow`.
- Range (visible segment): `=MethodHigh-MethodLow`.
- Midpoint (for an optional data label): `=(MethodLow+MethodHigh)/2`.
- Current price column repeating the single input for the reference series: `=CurrentPrice`.
Order rows so the chart reads top to bottom in the sequence the user wants.

Chart tab. Build with the runtime’s spreadsheet chart API:
- Create a `BarChart`, set `type = "bar"` for horizontal bars and `grouping = "stacked"`, `overlap = 100`.
- Add the Base series first, then the Range series, from the Chart Data ranges.
- Set the Base series fill to no fill and no border so only the low-to-high range shows.
- Set categories to the method label range.
- Add the current price as a separate series (a thin marker) or document it as a reference line, and set its fill to a distinct color.
- Format the value axis number format to `#,##0.00` and title the chart Valuation Summary.

## Formula and formatting conventions
Blue font for input cells, black for formulas, green for links to other tabs. Never hardcode a number inside a formula; the Range is always `High-Low` and the current price is a single labeled input cell referenced everywhere. Use one consistent formula across each method row. Number formats: per share values as `#,##0.00` (or `#,##0.0` for EV in $mm), negatives in parentheses where relevant. Keep the Base series invisible so the bars float, and keep the current price series visually distinct.

## Checks
- Each range low less than or equal to high: `=IF(MethodLow<=MethodHigh,"ok","CHECK")` for every method.
- Every method has a non-blank label: flag blanks so no bar is unlabeled.
- Current price sits within the union of ranges, or note explicitly if it falls outside all of them.
- Base plus Range equals High for every row (proves the floating bar math): `=IF(Base+Range=MethodHigh,"ok","CHECK")`.
- No method row has a zero-width range unless intended; flag a low equal to high.

## Recalculate and verify
Always write live formulas, never paste computed numbers. After writing, recalculate the workbook headlessly so cached values and the chart source ranges populate, then scan all cells for #REF!, #DIV/0!, #VALUE!, and #NAME?. Confirm the chart references resolve and the Base series is invisible. Fix and recalculate in a loop until zero errors, then deliver the .xlsx.

## Inputs to gather
Valuation date, current share price (or current EV), and for each method the low and high implied value per share (or EV). If a method's range comes from another model, gather the link or the output figures. Confirm the method ordering and whether the chart is per share or enterprise value.

## Example
Hypothetical ranges per share: DCF 38.0 to 52.0, Trading Comps 36.0 to 48.0, Precedent Transactions 42.0 to 58.0, 52-Week Range 34.0 to 50.0, LBO 35.0 to 45.0, Analyst Targets 40.0 to 55.0, with a current price of 44.0. The chart shows six floating bars with the current price marked, and the checks confirm every low is at or below its high. All numbers are illustrative.
