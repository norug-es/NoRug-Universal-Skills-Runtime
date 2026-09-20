---
name: sum-of-the-parts
version: 1.0.0-chatgpt
domain: valuation
portable: true
dependencies: [trading-comps, dcf-model]
triggers: ["sotp", "sum of the parts", "segment valuation"]
description: Builds a sum-of-the-parts valuation .xlsx from scratch with live formulas across separate segments, SOTP, bridge, and checks tabs. Use when a user wants to value a multi-segment or conglomerate business by valuing each segment on its own appropriate multiple or method and aggregating to equity value.
---
# Sum-of-the-Parts (SOTP) Valuation

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
Use when the user wants to value a diversified company by breaking it into segments and valuing each on the multiple or method that fits its industry, then aggregating and bridging to equity value. Common for conglomerates, holding companies, and break-up or spin-off analysis. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling, without requiring an Excel add-in or plugin. Trigger on sum of the parts, SOTP, segment valuation, conglomerate value, or break-up value.

## What it builds
A workbook with these tabs:
- Cover: purpose, segment list, color legend, valuation date.
- Segments: per-segment financials and chosen multiple or method (blue inputs).
- SOTP: per-segment enterprise value and percent of total.
- Bridge: aggregate EV to equity value and per share.
- Checks: tie-outs and sanity flags.

## Build workflow
1. Create the four tabs and freeze header rows.
2. On Segments, lay out one row (or block) per segment with financials and the chosen multiple or method as blue inputs.
3. For multiple-based segments, compute segment EV = segment metric times segment multiple.
4. For any mini-DCF segment, build a small unlevered FCF and terminal block and link its EV in.
5. On SOTP, list each segment EV and compute its percent of total enterprise value.
6. Sum segment EVs to total enterprise value, subtracting unallocated corporate costs capitalized at a multiple.
7. On Bridge, subtract net debt and minorities, add stakes and investments, and divide by shares for per share.
8. On Checks, confirm the segment EVs sum and multiples are sane.
9. Recalculate with a supported spreadsheet calculation engine when available; otherwise validate formulas structurally and disclose that cached values require recalculation in Excel/Google Sheets.
10. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver the .xlsx.

## Tab-by-tab spec
Segments tab. One labeled block per segment (e.g. Segment A, Segment B, Corporate). Columns or rows (blue inputs): Segment revenue, Segment EBITDA, Segment EBIT, Method selector (1 = EV/EBITDA, 2 = EV/Revenue, 3 = mini-DCF), Chosen multiple, and for mini-DCF the FCF path, WACC, and terminal growth. Also Unallocated corporate cost (annual), Corporate cost capitalization multiple, Net debt, Minority interest at parent, Stakes and investments value, Diluted shares.

SOTP tab. One row per segment (green links to Segments). Formulas:
- Segment EV (multiple method): `=CHOOSE(MethodSelector, SegEBITDA*Multiple, SegRevenue*Multiple, MiniDCF_EV)`.
- Mini-DCF EV (where used): sum of `FCF_t/(1+WACC)^t` plus `FCF_N*(1+g)/(WACC-g)/(1+WACC)^N`.
- Corporate drag: `=-UnallocatedCost*CorporateCapMultiple` (a negative EV item).
- Total enterprise value: `=SUM(SegmentEVs)+CorporateDrag`.
- Percent of total per segment: `=SegmentEV/TotalEnterpriseValue` (show for every segment).

Bridge tab.
- Enterprise value: `=SOTP!TotalEnterpriseValue` (green link).
- Less net debt: `=-NetDebt`.
- Less minority interest: `=-MinorityInterest`.
- Plus stakes and investments: `=+StakesAndInvestments`.
- Equity value: `=EnterpriseValue-NetDebt-MinorityInterest+StakesAndInvestments`.
- Value per share: `=EquityValue/DilutedShares`.
- Optional implied blended EV/EBITDA: `=EnterpriseValue/SUM(SegmentEBITDA)` for a reasonableness read.

## Formula and formatting conventions
Blue font for input cells, black for formulas, green for links to other tabs. Never hardcode a number inside a formula; each segment multiple, the corporate cap multiple, net debt, minorities, stakes, and shares are all labeled input cells. Use one consistent EV formula across the segment rows via the method selector. Number formats: values as `#,##0.0` with negatives in parentheses, multiples as `0.0"x"`, percent of total to one decimal as `0.0%`. Name major items (TotalEV, NetDebt, Shares) for a clean Bridge.

## Checks
- Segment EVs sum correctly: `=SUM(SegmentEVs)+CorporateDrag` equals the TotalEV cell exactly; flag any mismatch.
- Percent of total across segments sums to 100% (allowing the corporate drag); flag if it does not reconcile.
- Each segment multiple within a sane industry band (input bounds per segment); flag outliers.
- Implied blended EV/EBITDA sits in a reasonable range versus the company's standalone trading level.
- Equity value bridge ties: EV less net debt and minorities plus stakes equals equity value.

## Recalculate and verify
Always write live formulas, never paste computed numbers. After writing, recalculate the workbook headlessly so cached values populate, then scan all cells for #REF!, #DIV/0!, #VALUE!, and #NAME?. Watch any mini-DCF Gordon denominator `WACC-g` and the percent-of-total divisions. Fix and recalculate in a loop until zero errors, then deliver the .xlsx.

## Inputs to gather
Valuation date, the segment list, per-segment revenue, EBITDA, EBIT, the method and multiple for each segment, any mini-DCF assumptions, unallocated corporate cost and its cap multiple, net debt, minority interest, stakes and investments, and diluted shares.

## Example
Hypothetical: Segment A EBITDA 300.0 $mm at 9.0x, Segment B EBITDA 150.0 $mm at 7.0x, Segment C valued by a mini-DCF, and a corporate cost drag of 20.0 $mm capitalized at 8.0x. Summing segment EVs less the corporate drag gives total enterprise value; after subtracting net debt of 500.0 $mm and adding a 100.0 $mm stake across 120.0 shares you reach an illustrative per share value. Segment A shows the largest percent of total. All numbers are illustrative.
