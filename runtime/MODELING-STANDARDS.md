# Modeling Standards

## Workbook architecture
- Separate assumptions/raw inputs, calculations, outputs and checks where practical.
- Use consistent period columns and fillable formulas.
- Prefer named or clearly labeled assumption cells over magic constants.
- Preserve auditability: a reviewer should be able to trace an output back to its inputs.

## Financial formatting
- Hardcoded assumptions: blue text.
- Same-sheet calculations: black text.
- Cross-sheet links: green text.
- External workbook links: red text.
- Attention/update assumptions: yellow fill.
- Zeros: `-`. Negatives: red parentheses. Multiples: `0.0x`. Percentages: consistent precision.
- State units in headers, e.g. `Revenue ($mm)`.

## Investment-banking layout
- Hide gridlines by default for new banking-style models.
- Use dark section headers with white text.
- Put borders above totals and sum the range directly above when appropriate.
- Right-align numeric columns; left-align labels; indent submetrics.

## Sources
For researched inputs, prefer filings, investor relations, regulator/official sources and directly attributable market data. Put source URLs in cell comments or an adjacent source field. Never present an unsourced live market input as verified.

## Scenario discipline
Keep Base/Bull/Bear (or equivalent) assumptions explicit. A scenario selector should change driver cells, not overwrite historical actuals.
