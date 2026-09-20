---
name: revenue-build
version: 1.0.0-chatgpt
domain: operating-model
portable: true
dependencies: [scenario-manager]
triggers: ["revenue build", "arr build", "driver based revenue"]
description: Builds a driver-based revenue forecast .xlsx with live formulas across separate drivers, build, and output tabs plus checks, rolling a customer or units schedule (beginning, adds, churn, ending) into revenue with Base/Bull/Bear scenario toggles. Use when someone needs a bottom-up revenue model, an ARR build, or a driver-based forecast for planning or a board deck.
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


# Revenue Build (Driver-Based Forecast)

## When to use
Use when revenue should be built bottom-up from real operating drivers rather than a single growth percentage: customers from marketing spend or a funnel, churn, ARPU, or volume times price by product line. Good for operating plans, ARR forecasts, and fundraising models that need a defensible bridge from drivers to the top line. The skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling; it should produce a standalone workbook without requiring an Excel add-in.

## What it builds
A workbook with six tabs:
- Cover: title, color legend, scenario selector, headline revenue and growth.
- Drivers: all blue inputs (starting customers, marketing spend, CAC or funnel rates, ARPU, churn, price, scenario multipliers).
- Revenue Build: the period-by-period customer or units schedule and revenue.
- Summary: annual revenue, growth, ending customers, and the scenario in force.
- Sensitivity: new-adds by churn Data Table driving ending ARR or revenue.
- Checks: roll-forward identity and sanity flags.

## Build workflow
1. Create the workbook and the six tabs in the order above.
2. On Drivers, lay out every input in blue with units; add a scenario cell (1=Base, 2=Bull, 3=Bear) named `scn`.
3. Set up the period header row (months or quarters) once and reference it everywhere.
4. Build the customer or units roll-forward on Revenue Build: beginning, adds, churn, ending.
5. Compute revenue each period from the schedule (customers times ARPU, or volume times price).
6. Build the Summary by aggregating periods to years.
7. Build the Sensitivity tab as a native two-variable Data Table.
8. Build the Checks tab with the roll-forward identity and growth sanity tests.
9. Recalculate with a supported spreadsheet calculation engine when available; otherwise validate formulas structurally and disclose that cached values require recalculation in Excel/Google Sheets.
10. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?); fix and re-recalculate in a loop, then deliver.

## Tab-by-tab spec

### Cover
- Title cell, model purpose line, and a build date.
- Color legend block: a blue swatch labelled "Input", black labelled "Formula", green labelled "Cross-tab link".
- Scenario echo: `=CHOOSE(scn,"Base","Bull","Bear")` pulling the active scenario from Drivers.
- Headline outputs as green cross-tab links: latest-year revenue `=Summary!<latest revenue cell>`, ending customers, and final-year YoY growth.
- A one-line read-me noting the workbook recalculates live in Excel and was verified error-free at build.

### Drivers
- B2 Scenario selector (blue, 1/2/3), named `scn`.
- Starting customers B5; ARPU per period B6; monthly churn % B7.
- Acquisition: marketing spend per period B8; CAC B9; new adds from spend `=B8/B9` (computed on Build, not here).
- Optional funnel: leads B10, lead-to-customer % B11.
- Scenario multipliers in a 3-column block (Base/Bull/Bear): adds multiplier row C14:E14, churn multiplier row C15:E15. Active values: B14 `=CHOOSE(scn,C14,D14,E14)`, B15 `=CHOOSE(scn,C15,D15,E15)`.
- Optional product-line block: price per line and volume per line for a volume times price build.

### Revenue Build
- Row 3 period headers 1..N (single series, referenced by all rows below).
- Beginning customers: period 1 `=Drivers!B5`; later periods `=<prior ending cell>`.
- New adds: `=Drivers!$B$8/Drivers!$B$9*Drivers!$B$14` (spend over CAC times active adds multiplier), or funnel `=Drivers!$B$10*Drivers!$B$11*Drivers!$B$14`. Use one consistent formula across the row.
- Churned: `=Beginning*Drivers!$B$7*Drivers!$B$15` (active churn multiplier).
- Ending customers: `=Beginning+Adds-Churned`.
- Revenue: `=Ending*Drivers!$B$6` (customers times ARPU), or for product lines `=SUMPRODUCT(price_range,volume_range)`.
- ARR (if subscription): `=Revenue*12` when periods are months, or annualize as appropriate.

### Summary
- Annual revenue: `=SUM(<the 12 monthly revenue cells for that year>)`.
- YoY growth: `=ThisYear/PriorYear-1`.
- Ending customers per year: last period ending of the year via a cross-tab link.
- Active scenario label: `=CHOOSE(scn,"Base","Bull","Bear")`.

### Sensitivity
- Top-left corner references ending ARR or final-period revenue `='Revenue Build'!<ending ARR cell>`.
- Column input: new-adds per period values. Row input: churn % values.
- Native two-variable Data Table with row input cell = Drivers churn and column input cell = a Drivers adds driver.

### Checks
- Roll-forward each period: `=IF(Ending=Beginning+Adds-Churned,"PASS","FAIL")` across all periods, then `=AND(...)`.
- Continuity: `=IF(Beginning_period_t=Ending_period_t-1,"PASS","FAIL")`.
- Growth sanity: flag if any YoY growth exceeds a blue cap input or is below a floor.
- Non-negative customers and revenue every period.

## Formula and formatting conventions
- Blue font for inputs (Drivers only). Black for in-tab formulas. Green for cross-tab links.
- No hardcoded numbers in formulas; constants live on Drivers as blue cells. Use absolute refs (`$B$7`) to driver cells so a row fills across periods cleanly.
- One consistent formula per row so it copies horizontally without edits.
- Customers as whole numbers with thousands separators; ARPU and revenue as currency; churn and growth as percent.
- Name `scn` and the ending-ARR cell so Checks and Sensitivity read clearly.

## Checks
- Ending = beginning + adds - churn every period (PASS/FAIL).
- Beginning of each period equals prior ending.
- YoY growth within a stated sane band.
- Customers and revenue never negative; churn between 0 and 1.

## Recalculate and verify
After writing, recalculate with a supported spreadsheet calculation engine when available so formula results are refreshed. Scan every sheet for #REF!, #DIV/0!, #VALUE!, #NAME?. Fix any offending formula or missing named range and recalculate again in a loop. Deliver only when the Checks tab shows all PASS and no error strings remain.

## Inputs to gather
- Starting customers or units and ARPU or price per line.
- Acquisition mechanism: marketing spend and CAC, or a funnel (leads and conversion).
- Churn rate per period and the period length (month or quarter).
- Scenario multipliers for adds and churn (Base/Bull/Bear).
- Forecast horizon (number of periods).

## Example
Hypothetical: start 1,000 customers, ARPU 50 per month, churn 3% monthly. Marketing spend 100,000 per month, CAC 500, so 200 new adds per month. Month-1 churn about 30 customers, ending about 1,170. Over 36 months under Base, customers ramp and monthly revenue grows; Bull applies a 1.2x adds and 0.8x churn multiplier. Sensitivity flexes adds from 150 to 300 against churn from 2% to 5% to show ending ARR.
