---
name: market-sizing
version: 1.0.0-chatgpt
domain: strategy
portable: true
dependencies: [scenario-manager]
triggers: ["tam", "sam", "som", "market sizing"]
description: Builds a TAM/SAM/SOM market-sizing .xlsx with live formulas across separate inputs, calculations, and outputs tabs plus checks, sizing the market both top-down and bottom-up and triangulating to a defensible range. Use when someone needs a market-size model, a TAM build, or a top-down vs bottom-up cross-check for a strategy or fundraising deck.
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


# Market Sizing (TAM/SAM/SOM)

## When to use
Use when you need to size a market and defend the number two independent ways: a top-down funnel from a broad population and a bottom-up build from units times price. Good for new-market entry, board decks, and fundraising where a single sourced figure is not credible on its own. The skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling; it should produce a standalone workbook without requiring an Excel add-in.

## What it builds
A workbook with seven tabs:
- Cover: title, color legend, scenario selector, headline TAM/SAM/SOM outputs.
- Assumptions: every blue input (population, filter percentages, ARPU, penetration, scenario multipliers).
- Top-Down: broad figure narrowed by funnel filters to TAM, SAM, SOM.
- Bottom-Up: units or accounts times ARPU times adoption, built up to SAM and SOM.
- Triangulation: both methods side by side, the gap, and the chosen defensible range.
- Sensitivity: penetration by ARPU Data Table driving SOM.
- Checks: ordering and tolerance tests with PASS/FAIL flags.

## Build workflow
1. Create the workbook and the seven tabs in the order above.
2. On Assumptions, lay out all inputs in blue with units in an adjacent column; add a scenario cell (1=Base, 2=Bull, 3=Bear).
3. Build Top-Down as a single downward funnel where each row multiplies the row above by one filter.
4. Build Bottom-Up from a unit count times ARPU times adoption, scaling to SAM and SOM.
5. Build Triangulation pulling both sets of figures via cross-tab links and computing the gap.
6. Add a 5-year SOM ramp using a penetration curve.
7. Build the Sensitivity tab as a native two-variable Data Table.
8. Build the Checks tab with ordering and tolerance formulas.
9. Recalculate with a supported spreadsheet calculation engine when available; otherwise validate formulas structurally and disclose that cached values require recalculation in Excel/Google Sheets.
10. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?); fix and re-recalculate in a loop, then deliver.

## Tab-by-tab spec

### Assumptions
- B2 Scenario selector (blue, 1/2/3). Name it `scn`.
- Block A Top-down inputs: B5 Broad population (e.g. number of businesses), B6 % addressable, B7 % serviceable, B8 target penetration %.
- Block B Bottom-up inputs: B11 reachable accounts, B12 ARPU per year, B13 adoption %, B14 SOM share of SAM %.
- Block C Scenario multipliers: rows for penetration multiplier and ARPU multiplier with three columns (Base/Bull/Bear), e.g. C17:E17. Pull the active one with `=CHOOSE(scn,C17,D17,E17)` into B17.
- Block D Ramp: B20 starting penetration %, B21 steady-state penetration %, B22 years to steady state (used by Top-Down ramp).

### Top-Down
- B3 Broad population `=Assumptions!B5`.
- B4 Addressable `=B3*Assumptions!B6`.
- B5 Serviceable (SAM) `=B4*Assumptions!B7`.
- B6 TAM `=B4` (full addressable spend) and label SAM as B5; keep TAM as the addressable layer, SAM as serviceable.
- B7 Penetration applied `=Assumptions!B8*Assumptions!B17` (B17 = active penetration multiplier).
- B8 SOM `=B5*B7`.
- All currency rows formatted as currency; percentage filters as %.

### Bottom-Up
- B3 Reachable accounts `=Assumptions!B11`.
- B4 ARPU `=Assumptions!B12*Assumptions!B18` (B18 = active ARPU multiplier).
- B5 SAM `=B3*B4*Assumptions!B13`.
- B6 SOM `=B5*Assumptions!B14`.
- TAM (bottom-up) B7 `=B3/Assumptions!B7*B4` to gross the reachable base back up to the serviceable-and-addressable layer for comparison.

### Triangulation
- Columns: B = Top-Down, C = Bottom-Up.
- Row TAM: B `='Top-Down'!B6`, C `='Bottom-Up'!B7`.
- Row SAM: B `='Top-Down'!B5`, C `='Bottom-Up'!B5`.
- Row SOM: B `='Top-Down'!B8`, C `='Bottom-Up'!B6`.
- Gap column D `=ABS(B-C)/AVERAGE(B,C)` per row (percentage gap between methods).
- Chosen range: Low `=MIN(B,C)`, High `=MAX(B,C)`, Midpoint `=AVERAGE(B,C)` for each of TAM/SAM/SOM.
- 5-year SOM ramp: a row of years 1-5; penetration each year `=Assumptions!B20+(Assumptions!B21-Assumptions!B20)*MIN(year/Assumptions!B22,1)`; SOM each year `=SAM_midpoint*penetration_year`.

### Sensitivity
- Corner cell top-left references SOM midpoint `=Triangulation!<SOM midpoint cell>`.
- Column input down the left: penetration % values. Row input across the top: ARPU values.
- Build a native two-variable Data Table with row input cell = Assumptions ARPU and column input cell = Assumptions penetration.

### Checks
- Ordering TAM>=SAM: `=IF(Triangulation!TAM_mid>=Triangulation!SAM_mid,"PASS","FAIL")`.
- Ordering SAM>=SOM: same pattern.
- Method tolerance: `=IF(Triangulation!gap_SOM<=Assumptions!tol,"PASS","FAIL")` where tol is a blue input (e.g. 0.30 for 30%).
- Non-negative SOM and penetration between 0 and 1.

## Formula and formatting conventions
- Blue font for inputs (Assumptions only). Black font for in-tab formulas. Green font for cross-tab links (the `=Tab!Cell` references).
- No hardcoded numbers inside formulas; every constant lives on Assumptions as a blue cell.
- One consistent formula per row so it fills cleanly across columns.
- Currency cells use a currency number format; percentages use a percent format with one decimal; units use thousands separators.
- Name key cells: `scn`, `tol`, and the SAM and SOM midpoints for readable Check and Sensitivity formulas.

## Checks
- SOM <= SAM <= TAM for the chosen range.
- Top-down vs bottom-up within the stated tolerance band on SOM, flagged PASS/FAIL.
- All percentages between 0 and 1; all sizes non-negative.
- Ramp penetration never exceeds steady-state penetration.

## Recalculate and verify
After writing, recalculate with a supported spreadsheet calculation engine when available so formula results are refreshed by a supported calculation engine when available. Scan every sheet for #REF!, #DIV/0!, #VALUE!, #NAME?. If any appear, fix the offending formula or missing named range and recalculate again. Only deliver once the Checks tab shows all PASS and no error strings remain.

## Inputs to gather
- The broad starting figure and its meaning (population, accounts, or industry spend).
- Addressable and serviceable filter percentages.
- ARPU or price per unit per year and the reachable account count.
- Target penetration, SOM share, and the tolerance band.
- Scenario multipliers for Base/Bull/Bear.

## Example
Hypothetical: broad population 500,000 businesses, 60% addressable, 50% serviceable gives SAM. ARPU 2,000 per year, 80% adoption, reachable 150,000 accounts gives a bottom-up SAM near 240M. Top-down SAM near 300M; gap about 22%, inside a 30% tolerance, so flag PASS and present a 240M to 300M SAM range with a 5-year SOM ramp from 2% to 8% penetration.
