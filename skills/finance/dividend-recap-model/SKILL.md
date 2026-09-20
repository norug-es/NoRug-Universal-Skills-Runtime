---
name: dividend-recap-model
version: 1.0.0-chatgpt
domain: private-equity
portable: true
dependencies: [debt-schedule, irr-moic-calculator]
triggers: ["dividend recap", "recapitalization", "sponsor dividend"]
description: Builds a dividend recapitalization .xlsx with live formulas across separate assumptions, new debt capacity, recap, returns impact, and checks tabs that sizes incremental debt to a target leverage, funds a dividend net of fees, and recomputes sponsor IRR and MOIC with the dividend as an early dated cash inflow. Use when someone asks to model a dividend recap, leveraging up to pay a sponsor dividend, or the return impact of an interim distribution.
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


# Dividend Recap Model

## When to use
Use when someone needs to size incremental debt to a target leverage, fund a dividend to equity holders net of financing fees, and see how that interim cash inflow lifts sponsor IRR while MOIC moves only modestly. The default outputs are recap proceeds, post-recap leverage, and the new IRR and MOIC. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling; it should produce a standalone workbook.

## What it builds
- Cover: title, color legend, named-range list.
- Assumptions: EBITDA, existing net debt, target leverage, fees, coverage inputs, dates.
- New Debt Capacity: incremental capacity from target leverage net of fees.
- Recap: dividend funded, pro forma debt, pro forma leverage.
- Returns Impact: sponsor IRR and MOIC before and after the recap as dated flows.
- Checks: post-recap leverage equals target, dividend within capacity, coverage passes.

## Build workflow
1. Create the workbook and the six tabs above.
2. On Assumptions, enter blue inputs and define named ranges.
3. Compute incremental debt capacity on New Debt Capacity.
4. On Recap, fund the dividend net of fees and compute pro forma leverage.
5. On Returns Impact, recompute IRR and MOIC inserting the dividend as a dated inflow.
6. Wire Checks to TRUE/FALSE tests.
7. Apply number formats and the color convention.
8. Recalculate the workbook headless so all formulas compute.
9. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver.

## Tab-by-tab spec

### Cover
- Title, one-line purpose, build date.
- Color legend: blue = input, black = formula, green = cross-tab link.
- Named-range index: EBITDA, ExistingND, TargetLev, NewRate, FeePct and their cells.
- Exit-equity basis toggle (enterprise-driven so debt reduces residual equity, or fixed equity) wired by data validation; Returns Impact reads it.

### Assumptions (all blue)
- B2 EBITDA, B3 Existing net debt, B4 Target net debt/EBITDA, B5 New debt interest rate.
- B6 Financing fees % of new debt, B7 Minimum interest coverage (EBITDA/interest), B8 Minimum cash.
- B9 Entry date, B10 Recap date, B11 Exit date, B12 Original equity invested, B13 Projected exit equity.
- Named ranges: EBITDA, ExistingND, TargetLev, NewRate, FeePct.

### New Debt Capacity
- Target net debt: `=TargetLev*EBITDA`.
- Gross incremental debt: `=MAX(0, TargetND - ExistingND)`.
- Financing fees: `=GrossIncremental*FeePct`.
- Net dividend capacity: `=GrossIncremental - Fees`.

### Recap
- Dividend to equity: `=MIN(NetDividendCapacity, ProposedDividend)` (proposed is a blue cap, default equals capacity).
- Pro forma net debt: `=ExistingND + GrossIncremental` (fees reduce cash, debt rises by gross).
- Pro forma leverage: `=ProFormaND/EBITDA` formatted 0.0x.
- New annual interest: `=ProFormaND*NewRate` (or interest on incremental tranche if existing is fixed).
- Interest coverage: `=EBITDA/TotalInterest` formatted 0.0x.

### Returns Impact
- Pre-recap flows: `{-OriginalEquity at Entry, ExitEquity at Exit}`.
- Pre-recap MOIC: `=ExitEquity/OriginalEquity`; Pre-recap IRR: `=XIRR({-OrigEquity, ExitEquity}, {Entry, Exit}, 0.1)`.
- Post-recap exit equity: `=ExitEquity - Dividend` if exit value is enterprise-driven the higher debt reduces residual equity by roughly the dividend; state the assumption.
- Post-recap flows: `{-OriginalEquity at Entry, +Dividend at Recap, +PostRecapExitEquity at Exit}`.
- Post-recap MOIC: `=(Dividend + PostRecapExitEquity)/OriginalEquity` formatted 0.0x.
- Post-recap IRR: `=XIRR({-OrigEquity, Dividend, PostRecapExitEquity}, {Entry, Recap, Exit}, 0.1)`.
- The dividend pulls cash forward, so IRR rises even though MOIC is roughly flat; show both deltas explicitly.
- IRR delta: `=PostRecapIRR-PreRecapIRR` formatted 0.0%. MOIC delta: `=PostRecapMOIC-PreRecapMOIC` formatted 0.0x.
- Years to recap: `=(RecapDate-EntryDate)/365`, the lever on how much the early cash lifts IRR.

### Workbook build notes
- Write both XIRR formulas (pre and post) as strings with a 0.1 guess; never paste the resolved rate.
- Build the post-recap flow as three dated rows (entry outflow, recap dividend inflow, exit inflow) so XIRR reads distinct dates.
- Use `DefinedName` for EBITDA, ExistingND, TargetLev, NewRate, FeePct so capacity and leverage formulas read by name.

## Formula and formatting conventions
Blue font for inputs (Assumptions, proposed dividend cap). Black for in-tab formulas. Green for cross-tab links (`Assumptions!`, `NewDebtCapacity!`, `Recap!`). No hardcoded numbers inside formulas; use named ranges. One consistent formula per row. Leverage and coverage as 0.0x, percentages 0.0%, dollars with separators, MOIC 0.0x.

## Checks
- Post-recap leverage equals target: `=ROUND(ProFormaLeverage-TargetLev,4)=0` (when dividend uses full capacity).
- Dividend within capacity: `=Dividend<=NetDividendCapacity`.
- Coverage still passes: `=InterestCoverage>=MinCoverage`.
- IRR improved: `=PostRecapIRR>=PreRecapIRR`.
- Pro forma net debt rises by gross incremental: `=ROUND(ProFormaND-(ExistingND+GrossIncremental),2)=0`.
- Dividend non-negative: `=Dividend>=0` (no recap if target leverage is below existing).

## Recalculate and verify
After writing, recompute headless so XIRR before and after and the leverage math resolve. Scan all cells for #REF!, #DIV/0!, #VALUE!, #NAME?. A common failure is coverage #DIV/0! when interest is zero (no incremental debt drawn); guard the denominator. Confirm both XIRR formulas converge with the 0.1 guess. Recalc until clean, then deliver.

## Inputs to gather
EBITDA, existing net debt, target net debt/EBITDA, new debt rate and financing fees, minimum coverage and cash, original equity invested, projected exit equity, and entry, recap, and exit dates.

## Example
Hypothetical: EBITDA 50, existing net debt 150 (3.0x), target 4.5x. Target net debt 225, gross incremental 75, fees 2% give a net dividend near 73.5. Pro forma leverage 4.5x; coverage still above a 2.0x floor. With original equity 100 and exit equity 300, pulling a ~74 dividend at the recap date lifts IRR by several points while MOIC stays near 2.7x to 2.9x.
