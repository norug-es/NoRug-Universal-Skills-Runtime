# NoRug Financial Skills Runtime v1 — ChatGPT

This package turns 25 financial-modeling skills into a vendor-neutral knowledge/runtime layer optimized for ChatGPT Projects and spreadsheet-capable ChatGPT environments.

## Operating order
1. Read `MASTER-INSTRUCTIONS.md`.
2. Route the request with `SKILL-ROUTER.md`.
3. Load the smallest set of skills needed.
4. Resolve data/source requirements before building.
5. Execute with the current environment's spreadsheet tooling.
6. Apply `MODELING-STANDARDS.md` and `QA-GATES.md`.
7. Deliver the workbook plus a concise description of assumptions, sources, checks, and unresolved limitations.

## Core principle
Skills describe **what to build, why, formulas, assumptions, dependencies and validation**. Runtime/tool instructions describe **how to physically create the workbook**. Never hard-couple domain knowledge to Claude, ChatGPT, openpyxl, LibreOffice, Excel add-ins, or any single execution engine.

## Truthfulness gate
Do not report PASS for recalculation, formula evaluation, visual rendering, source verification, or workbook integrity unless that check was actually executed. Use `NOT_VERIFIED` rather than guessing.

## Missing inputs
Prefer reasonable, explicitly labeled placeholders only when the user asks for a template or illustrative model. For a real-company model, acquire current values from reliable sources when browsing is available and mark each sourced input.

## Composite execution
A parent skill may invoke dependencies listed in its frontmatter. Avoid duplicating logic: use the dependency's method and surface its outputs into the parent model.
