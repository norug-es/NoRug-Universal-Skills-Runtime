---
name: monte-carlo
version: 1.0.0-chatgpt
domain: decision-support
portable: true
dependencies: []
triggers: ["monte carlo", "simulation", "probability distribution"]
description: Builds a Monte Carlo simulation of a model output in a .xlsx with no add-in, using either native RAND-driven trials or a numpy trial engine, plus a percentile and threshold summary, a histogram, and a recalc check, then delivers the workbook. Use when someone wants a distribution of outcomes instead of a single point estimate.
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


# Monte Carlo Simulation (No Add-In)

## When to use
Use when a model output (NPV, IRR, EPS, payback) depends on uncertain inputs and a single point estimate hides the risk. This skill BUILDS a downloadable .xlsx from scratch using ChatGPT spreadsheet and Python tooling, simulating thousands of trials and summarizing the output distribution, with a recalc-and-verify pass. It needs no Crystal Ball, no @RISK, and no add-in, and it does not require an Excel add-in.

## What it builds
Five tabs: `Cover` (run settings and summary), `Assumptions` (each uncertain input and its distribution), `Simulation` (the per-trial engine and outputs), `Results` (trial outputs, percentile and threshold summary, histogram), and `Checks`.

## Build workflow
1. Identify the output cell and the uncertain inputs feeding it.
2. For each uncertain input, choose a distribution and its parameters (normal mean/sd, triangular min/mode/max, uniform min/max).
3. Choose a trial count (state it; 5,000 to 10,000 is a reasonable default).
4. Build BOTH paths: the native RAND-driven Data Table trials and the numpy trial engine (see spec).
5. Compute the percentile summary (P5, P10, P50, P90, P95), mean, standard deviation, and at least one threshold probability such as P(IRR < hurdle).
6. Build a histogram chart of the trial outputs.
7. Add the Checks tab.
8. Recalculate with a supported spreadsheet calculation engine when available; otherwise validate formulas structurally and disclose that cached values require recalculation in Excel/Google Sheets.
9. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), confirm checks pass, then deliver the .xlsx.

## Tab-by-tab spec

### Assumptions tab
One row per uncertain input: name, distribution type, and parameter cells (all blue).
- Normal: mean, sd. The live draw is `=NORM.INV(RAND(),mean,sd)`.
- Uniform: min, max. Draw `=min+(max-min)*RAND()`.
- Triangular: min, mode, max. Draw with the inverse-CDF formula using `u=RAND()` and `Fc=(mode-min)/(max-min)`:
  `=IF(u<Fc, min+SQRT(u*(max-min)*(mode-min)), max-SQRT((1-u)*(max-min)*(max-mode)))`.
- Note correlation caveat: independent RAND() draws assume inputs are uncorrelated. If drivers move together (price and volume, rate and default), independent sampling understates tail risk; flag it and, if needed, drive correlated inputs from a shared factor rather than separate RAND() calls.

### Simulation tab (native path)
- A row of live draw cells, one per input, using the formulas above; these feed the model so the output cell recomputes per recalculation.
- The output formula `=Model!B40` sits at the corner of a one-variable Data Table.
- Trial index 1..N runs DOWN a column; the Data Table's Column input cell points at an UNUSED scratch cell (not referenced by the model). Because each row forces a full recalculation, every RAND() reseeds and the captured output differs per row. Excel writes `{=TABLE(,<scratch cell>)}` down the trial column.
- This native trick works only after recalculation in a real engine; the workbook writer may create the structure without evaluating the Data Table.

### Simulation and Results tabs (numpy path, recommended via code)
- In Python, sample each input distribution N times with numpy (`np.random.normal`, `np.random.triangular`, `np.random.uniform`), evaluate the output function across all N trials vectorized, and write the N trial outputs as plain values to a `Results` column.
- This is deterministic to deliver, avoids volatile RAND() churn, and lets you compute the summary directly.

### Results tab (summary and chart)
- Percentile summary as live formulas over the trial column: `=PERCENTILE.INC(trials,0.05)` for P5, then 0.10, 0.50, 0.90, 0.95.
- `=AVERAGE(trials)` mean and `=STDEV.S(trials)` standard deviation.
- Threshold probability, for example `=COUNTIF(trials,"<"&hurdle)/COUNT(trials)` for P(output < hurdle).
- Histogram: bin the trials (FREQUENCY over a bin column or numpy histogram counts) and insert a bar/column chart of bin counts so the shape is visible.

### Checks tab
- Trial count stated and matches: `=(COUNT(trials)=Cover!B3)` TRUE.
- Summary stats present: P5, P10, P50, P90, P95, mean, sd all non-blank.
- Percentiles monotonic: `=AND(P5<=P10,P10<=P50,P50<=P90,P90<=P95)` TRUE.
- Histogram present (chart object on Results).

### Trial count guidance
- More trials tighten the percentile estimates; the standard error of a percentile shrinks roughly with the square root of the trial count, so going from 1,000 to 10,000 reduces that error scale to about 31.6% of the original (about a 68.4% reduction).
- For headline percentiles (P5, P95) and small threshold probabilities, lean toward 10,000 trials; the tails need more samples than the median.
- State the trial count on the Cover tab so the result is reproducible and the count check has a reference value.

### Workbook build notes
- For a Python simulation path, write trial outputs as plain numeric values; do not store them as formulas, since they are sampled data, not derived cells.
- Write the percentile, mean, sd, and threshold cells as formula strings over the trial range so they stay live if a user edits trials.
- Build the histogram with the runtime’s supported spreadsheet chart API, feeding a bin-label column and a FREQUENCY (or precomputed count) column as the data series.
- Seed the simulation RNG (for example `np.random.default_rng(seed)` when using NumPy) so a rebuild reproduces the same distribution, and note the seed on the Cover tab.

### Distribution sanity
- Confirm sampled means and spreads roughly match the stated parameters before wiring them in (a triangular with mode outside min/max, or a negative sd, is a common parameter error).
- For inputs bounded by zero (volumes, prices), prefer triangular or a truncated draw over a wide normal that can sample negatives and inject #VALUE! or nonsensical outputs.

## Formula and formatting conventions
- Blue font for distribution parameters, trial count, and the hurdle/threshold.
- Black font for in-tab formulas (draws, percentiles, summary stats).
- Green font for cross-tab links such as `=Model!B40`.
- No hardcodes where a formula belongs: percentile and probability cells are always formulas over the live trial range, never typed numbers.
- One consistent formula per row or column: the same draw formula per input, the same `PERCENTILE.INC` pattern down the summary block.
- Number formats: rates `0.0%`, currency `#,##0`, probabilities `0.0%`. Label every parameter with its units.

## Checks
See the Checks tab: trial count stated and matches the data, all summary stats present, percentiles monotonic, histogram present. All must hold.

## Recalculate and verify
Save the workbook and recalculate with a supported spreadsheet calculation engine when available so `{=TABLE(...)}`, NORM.INV, RAND, and percentile formulas populate. If the runtime cannot evaluate Data Tables, mark that path `STRUCTURALLY_VALIDATED_NOT_RECALCULATED` and rely on the explicit simulation path for verified outputs. Reload, scan for #REF!, #DIV/0!, #VALUE!, #NAME?. For the native path, confirm the trial column shows varied values (not a repeated constant, which means the scratch cell was wrong). Confirm percentiles are monotonic and the histogram rendered. Fix and loop until clean, then deliver.

## Inputs to gather
- Path to the model, the output cell, and each uncertain input cell.
- A distribution and its parameters for every uncertain input.
- The trial count and any correlation between inputs.
- The threshold(s) for the probability metric (for example the IRR hurdle).

## Example
Hypothetical NPV model with two uncertain inputs: revenue growth normal (mean 4%, sd 2%) and gross margin triangular (min 50%, mode 55%, max 58%). Running 10,000 trials gives a hypothetical distribution with P5 of 210, P50 of 760, P95 of 1,430 in hypothetical units, mean 770, sd 380, and P(NPV < 0) of 6.5%. The histogram shows a right-skewed shape and the percentiles increase monotonically, confirming the run is valid.
