# Porting & Audit Report

## Scope
Converted all 25 source skills from a Claude-specific Excel workflow into a vendor-neutral ChatGPT-oriented methodology/runtime package. The original financial logic was retained except where a concrete defect or portability issue was identified.

## Changes applied
- Removed Claude / Claude-for-Excel coupling.
- Removed mandatory `openpyxl` and LibreOffice implementation assumptions from the domain layer.
- Added a common ChatGPT execution contract to every skill.
- Added domain, triggers, dependency metadata and composition graph.
- Added runtime-wide modeling standards and explicit QA gates.
- Added a truthfulness rule preventing false claims of recalculation or PASS.
- Generalized chart/workbook implementation to the spreadsheet APIs available in the active ChatGPT environment.

## Corrected methodology issue
`monte-carlo`: source text said that increasing trials from 1,000 to 10,000 “roughly halves the noise” under square-root scaling. Under a `1/sqrt(N)` error scale, the new level is `sqrt(1000/10000)=0.3162`, i.e. about 31.6% of the original (about 68.4% lower). The port corrects this statement.

## Important boundary
This is a structural and implementation-portability audit plus targeted methodology correction; it is **not** a legal/accounting opinion or a certification that every formula is appropriate for every jurisdiction, security or transaction. Each live model must still be validated against its actual fact pattern and source data.
