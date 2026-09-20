---
name: precedent-transactions
version: 1.0.0-chatgpt
domain: valuation
portable: true
dependencies: []
triggers: ["precedent transactions", "transaction comps", "deal comps"]
description: Builds a precedent transactions analysis .xlsx from scratch with live formulas across separate deals input, calculations, output, and checks tabs. Use when a user wants to value a subject company off past M&A deals using transaction EV/Revenue and EV/EBITDA multiples and control premia.
---
# Precedent Transactions Analysis

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
Use when the user wants a relative valuation anchored on prices paid in past acquisitions of similar companies, capturing the control premium that trading comps miss. Common in IB and PE for takeover or sale-side work. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling and pandas, without requiring an Excel add-in or plugin. Trigger on precedent transactions, deal comps, transaction multiples, control premium, or M&A comps.

## What it builds
A workbook with these tabs:
- Cover: purpose, deal set summary, color legend, analysis date.
- Deals Input: one row per past deal with raw deal and target financial data (blue inputs).
- Calcs: transaction enterprise value, multiples, and implied premium per deal.
- Output: mean and median multiples and premia, with the implied valuation range applied to the subject.
- Checks: premium and multiple sanity flags.

## Build workflow
1. Create the four tabs and freeze the header row on each data tab.
2. On Deals Input, lay out one row per deal with raw inputs as blue cells (generic acquirer and target placeholders).
3. On Calcs, compute offer equity value, transaction EV, EV/Revenue, EV/EBITDA, and implied premium per deal.
4. Add a clean flag column to exclude outlier deals from the statistics.
5. On Output, compute mean and median of each multiple and the premium across the clean set.
6. Apply a chosen multiple range to the subject metric to derive implied EV and equity value range.
7. Optionally derive an implied offer per share by applying the premium range to the unaffected price.
8. On Checks, add premium and multiple bound flags and the control premium note.
9. Recalculate with a supported spreadsheet calculation engine when available; otherwise validate formulas structurally and disclose that cached values require recalculation in Excel/Google Sheets.
10. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver the .xlsx.

## Tab-by-tab spec
Deals Input tab. One row per deal. Columns (blue inputs): Announced date, Acquirer (e.g. Acquirer A), Target (e.g. Target A), Offer price per share, Target diluted shares, Target total debt, Target cash, Target minority interest, Target preferred, Unaffected share price (pre-announcement), Target LTM revenue, Target LTM EBITDA. Keep generic placeholders only, never real company names.

Calcs tab. One row per deal, linking to Deals Input (green links). Formulas:
- Offer equity value: `=OfferPrice*TargetDilutedShares`.
- Net debt: `=TargetDebt-TargetCash`.
- Transaction EV: `=OfferEquityValue+NetDebt+Minority+Preferred`.
- EV/Revenue: `=TransactionEV/TargetLTMRevenue`.
- EV/EBITDA: `=TransactionEV/TargetLTMEBITDA`.
- Implied premium: `=OfferPrice/UnaffectedPrice-1`.
- Days since announcement (optional aging): `=AnalysisDate-AnnouncedDate`.
- Clean flag: `=IF(OR(TransactionEV<=0,EVEBITDA>UpperBound,EVEBITDA<LowerBound,Premium>PremiumCap),0,1)` with bounds as inputs.

Output tab. Across the clean deal set, for each multiple and the premium:
- Median: `=MEDIAN(IF(CleanFlagRange=1,MetricRange))` as an array, or use a helper clean column.
- Mean: `=AVERAGEIF(CleanFlagRange,1,MetricRange)`.
Apply to the subject:
- Implied EV low: `=ChosenLowMultiple*SubjectMetric`; high uses the high multiple.
- Implied equity value: `=ImpliedEV-SubjectNetDebt-SubjectMinority-SubjectPreferred`.
- Implied per share from multiples: `=ImpliedEquity/SubjectDilutedShares`.
- Implied offer per share from premium: `=SubjectUnaffectedPrice*(1+ChosenPremium)` for low and high premium.
Show both the multiple-based and premium-based ranges so the user sees the control premium effect.

## Formula and formatting conventions
Blue font for input cells, black for formulas, green for links to other tabs. Never hardcode a number inside a formula; multiple bounds, premium cap, chosen statistic, and subject metrics are all labeled input cells. Use one consistent formula across each deal row. Number formats: values as `#,##0.0` with negatives in parentheses, multiples as `0.0"x"`, premia and percentages to one decimal as `0.0%`, dates as a clear date format. Name major ranges (CleanFlag, EVEBITDA, Premium, SubjectEBITDA).

## Checks
- Implied premium reasonable: flag if negative or above the premium cap input (suggests a data error or special situation).
- Transaction EV greater than zero for every deal.
- EV/EBITDA within sane bounds (input upper and lower); auto-exclude outliers via the clean flag.
- Control premium note: confirm the precedent median EV/EBITDA sits at or above the trading comps median; flag if it is unexpectedly lower.
- Subject implied range low less than or equal to high for both the multiple and premium methods.

## Recalculate and verify
Always write live formulas, never paste computed numbers. After writing, recalculate the workbook headlessly so cached values populate, then scan all cells for #REF!, #DIV/0!, #VALUE!, and #NAME?. Watch EBITDA divisions and unaffected price divisions for zero denominators. Fix and recalculate in a loop until zero errors, then deliver the .xlsx.

## Inputs to gather
Analysis date, the list of precedent deals, for each deal the announced date, generic acquirer and target labels, offer price, target shares, debt, cash, minorities, preferred, unaffected price, and target LTM revenue and EBITDA. For the subject: LTM revenue and EBITDA, net debt, minorities, preferred, diluted shares, and unaffected price, plus the multiple and premium range to anchor on.

## Example
Hypothetical deal set of four acquisitions with EV/EBITDA multiples of 9.0x, 10.5x, 11.0x, and 13.5x and implied premia of 25.0%, 30.0%, 35.0%, and 45.0%. Median multiple near 10.8x and median premium near 32.5%. Applying a 10.0x to 12.0x range to a subject LTM EBITDA of 250.0 $mm gives a multiple-based EV range, while a 25.0% to 35.0% premium on a 40.0 unaffected price gives a premium-based offer range. All numbers are illustrative.
