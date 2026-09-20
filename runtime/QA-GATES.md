# QA Gates

A workbook is deliverable only when applicable gates are PASS or explicitly marked NOT_VERIFIED with a reason.

## Structural
- Workbook opens/exports successfully.
- Required sheets exist and are named consistently.
- No duplicate table/range identifiers.
- Key formulas reference intended periods and assumptions.

## Formula integrity
Scan for `#REF!`, `#DIV/0!`, `#VALUE!`, `#NAME?`, `#N/A` where inappropriate. Inspect key output ranges with formulas and values. Check likely circular references.

## Finance integrity
Apply model-specific tie-outs: balance sheet balance, cash-flow reconciliation, debt roll-forward, EV-to-equity bridge, sources=uses, waterfall=distributable proceeds, scenario/sensitivity anchors, etc.

## Visual
Inspect/render important sheets where runtime supports it. Verify readable widths, formats, titles, units, totals, legends and charts.

## Provenance
Inputs obtained from research have a source. Assumptions are labeled as assumptions. Historical values are not mixed with forecast values without clear separation.

## Recalculation status
Use one of: `VERIFIED_RECALCULATED`, `STRUCTURALLY_VALIDATED_NOT_RECALCULATED`, `NOT_APPLICABLE`. Never claim recalculation from formula text alone.
