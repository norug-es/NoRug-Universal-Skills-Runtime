---
name: trading-comps
version: 1.0.0-chatgpt
domain: valuation
portable: true
dependencies: []
triggers: ["trading comps", "comparable companies", "public comps"]
description: Builds a comparable companies analysis .xlsx from scratch with live formulas across separate comps input, calculations, output, and checks tabs. Use when a user wants to value a subject company off a peer set using EV/Revenue, EV/EBITDA, EV/EBIT, and P/E multiples with summary statistics.
---
# Trading Comparables (Comps) Analysis

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
Use when the user wants a relative valuation of a subject company against a set of public peers, deriving implied enterprise and equity value from peer trading multiples. Common in IB and PE for a market check alongside a DCF. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling and pandas, without requiring an Excel add-in or plugin. Trigger on comps, comparable companies, peer multiples, EV/EBITDA, or trading multiples.

## What it builds
A workbook with these tabs:
- Cover: purpose, peer set list, color legend, pricing date.
- Comps Input: one row per comparable with raw market and financial data (blue inputs).
- Calcs: market cap, enterprise value, and every multiple per comparable.
- Output: mean, median, 25th and 75th percentile, and the implied valuation range applied to the subject.
- Checks: sanity flags and outlier handling.

## Build workflow
1. Create the four tabs and freeze the header row on each data tab.
2. On Comps Input, lay out one row per peer with raw inputs as blue cells.
3. On Calcs, compute diluted shares (treasury stock method), market cap, and enterprise value per peer.
4. Compute EV/Revenue, EV/EBITDA, EV/EBIT, and P/E for LTM and forward per peer, all as consistent row formulas.
5. Add a clean flag column to include or exclude outliers from the statistics.
6. On Output, compute mean, median, and percentiles across the clean set for each multiple.
7. Apply a chosen multiple range to the subject metric to derive implied EV and equity value range.
8. On Checks, add EV and multiple bound flags.
9. Recalculate with a supported spreadsheet calculation engine when available; otherwise validate formulas structurally and disclose that cached values require recalculation in Excel/Google Sheets.
10. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver the .xlsx.

## Tab-by-tab spec
Comps Input tab. One row per comparable. Columns (blue inputs): Company label (generic, e.g. Peer A), Share price, Basic shares, Options outstanding, Average strike, Total debt, Cash and equivalents, Minority interest, Preferred equity, LTM Revenue, LTM EBITDA, LTM EBIT, LTM net income, Forward revenue, Forward EBITDA, Forward EPS. Keep the subject company on its own clearly labeled row at the bottom or on Output.

Calcs tab. One row per comparable, linking to Comps Input (green links). Formulas:
- Treasury stock method dilution: `=MAX(0,(SharePrice-Strike)/SharePrice)*Options`.
- Diluted shares: `=BasicShares+TSMdilution`.
- Market cap: `=SharePrice*DilutedShares`.
- Net debt: `=TotalDebt-Cash`.
- Enterprise value: `=MarketCap+NetDebt+MinorityInterest+Preferred`.
- EV/Revenue LTM: `=EV/LTMRevenue`; EV/EBITDA LTM: `=EV/LTMEBITDA`; EV/EBIT LTM: `=EV/LTMEBIT`.
- P/E LTM: `=MarketCap/LTMNetIncome` or `=SharePrice/(LTMNetIncome/DilutedShares)`.
- Forward multiples: same pattern using forward revenue, EBITDA, and EPS.
- Clean flag: `=IF(OR(EV<=0,EVEBITDA>UpperBound,EVEBITDA<LowerBound),0,1)` where bounds are inputs.

Output tab. For each multiple build summary stats across the clean set using array-style conditions so excluded peers drop out:
- Median: `=MEDIAN(IF(CleanFlagRange=1,MultipleRange))` entered as an array, or use a helper clean column.
- Mean: `=AVERAGEIF(CleanFlagRange,1,MultipleRange)`.
- 25th percentile: `=PERCENTILE.INC(CleanMultipleRange,0.25)`; 75th: `=PERCENTILE.INC(CleanMultipleRange,0.75)`.
Then apply to the subject:
- Implied EV low: `=ChosenLowMultiple*SubjectMetric`; high uses the high multiple.
- Implied equity value: `=ImpliedEV-SubjectNetDebt-SubjectMinority-SubjectPreferred`.
- Implied per share: `=ImpliedEquity/SubjectDilutedShares`.
Let the user pick which statistic anchors the low and high (for example 25th to 75th percentile of EV/EBITDA).

## Formula and formatting conventions
Blue font for input cells, black for formulas, green for links to other tabs. Never hardcode a number inside a formula; the multiple bounds, chosen statistic selector, and subject metrics are all labeled input cells. Use one consistent formula across each peer row. Number formats: prices and values as `#,##0.0` with negatives in parentheses, multiples as `0.0"x"`, percentages to one decimal as `0.0%`. Name major ranges (CleanFlag, EVEBITDA_LTM, SubjectEBITDA) for readable Output formulas.

## Checks
- EV greater than zero for every peer; flag negatives that signal a data error.
- Each multiple within sane bounds (input upper and lower); flag and auto-exclude outliers via the clean flag.
- Market cap reconciles: share price times diluted shares; spot-check one peer by hand.
- Subject implied per share range low less than or equal to high.
- Count of clean peers shown so the statistics are not driven by one name.

## Recalculate and verify
Always write live formulas, never paste computed numbers. After writing, recalculate the workbook headlessly so cached values populate, then scan all cells for #REF!, #DIV/0!, #VALUE!, and #NAME?. Watch P/E divisions where net income could be zero or negative. Fix and recalculate in a loop until zero errors, then deliver the .xlsx.

## Inputs to gather
Pricing date, peer list, for each peer the share price, share count and option data, debt, cash, minorities, preferred, and the revenue, EBITDA, EBIT, net income, and forward figures. For the subject: the same metrics, net debt, minorities, preferred, and diluted shares, plus which multiple and percentile range to anchor on.

## Example
Hypothetical peer set of five names with EV/EBITDA LTM multiples of 7.5x, 8.2x, 9.0x, 9.8x, and 12.5x. Flag the 12.5x as an outlier and exclude it; the clean median sits near 8.6x. Applying an 8.0x to 9.5x range to a subject LTM EBITDA of 250.0 $mm gives an implied EV range, and after subtracting net debt of 300.0 $mm across 80.0 shares yields a hypothetical per share range. All numbers are illustrative.
