---
name: management-incentive-plan
version: 1.0.0-chatgpt
domain: private-equity
portable: true
dependencies: [pe-returns-waterfall, irr-moic-calculator]
triggers: ["management incentive", "sweet equity", "management ratchet"]
description: Builds a management incentive plan .xlsx with live formulas across separate cap table, MIP, exit returns, and checks tabs that models sweet equity, a preferred or loan-note stack, a ratchet, and the equity split at exit between sponsor and management. Use when someone asks to model management equity, sweet equity, an exit waterfall for ordinary shares, or a management ratchet that steps up on IRR or MOIC hurdles.
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


# Management Incentive Plan

## When to use
Use when someone needs a pro forma cap table and an exit split that pays a preferred or loan-note stack first, then divides residual ordinary equity, with a management ratchet that steps management's share up as sponsor returns clear hurdles. The default outputs are management and sponsor proceeds, MOIC, and IRR. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling; it should produce a standalone workbook.

## What it builds
- Cover: title, color legend, named-range list.
- Cap Table: pro forma instruments, amounts invested, and ownership percentages.
- MIP: sweet equity, option pool, ratchet bands keyed to sponsor IRR or MOIC.
- Exit Returns: exit equity distributed through the stack then split, with proceeds, MOIC, IRR.
- Checks: ownership sums to 100%, proceeds reconcile, ratchet bands continuous.

## Build workflow
1. Create the workbook and the five tabs above.
2. Build the Cap Table with blue invested amounts and computed ownership percentages.
3. On MIP, lay out sweet equity, pool, and the ratchet band table.
4. On Exit Returns, cascade exit equity through preferred and loan notes, then split ordinary.
5. Apply the ratchet via IF/CHOOSE keyed to sponsor MOIC or IRR.
6. Wire Checks to TRUE/FALSE tests.
7. Apply number formats and the color convention.
8. Recalculate the workbook headless so all formulas compute.
9. Verify zero formula errors (#REF!, #DIV/0!, #VALUE!, #NAME?), fix in a loop, then deliver.

## Tab-by-tab spec

### Cover
- Title, one-line purpose, build date.
- Color legend: blue = input, black = formula, green = cross-tab link.
- Named-range index: OrdEquityTotal, PrefBalance, SponsorOrd%, MgmtOrd%, PoolOrd% and their cells.
- Ratchet basis toggle (MOIC or IRR) wired by data validation; the MIP tab reads it.

### Cap Table
- Rows: Sponsor loan notes/preferred, Sponsor ordinary, Management sweet equity, Option pool.
- Column B Amount Invested (blue), C Instrument type, D Coupon/PIK rate (blue).
- Ordinary ownership %: `=OrdinaryInvested_row / SUM(Ordinary invested range)`.
- Total invested: `=SUM(B:B)`. Define named ranges OrdEquityTotal, PrefBalance, SponsorOrd%, MgmtOrd%, PoolOrd%.

### MIP
- Sweet equity amount and management base ordinary %.
- Option pool % of ordinary.
- Ratchet band table: column A Threshold (sponsor MOIC e.g. 2.0x, 2.5x, 3.0x), column B Management ordinary % at that band (blue inputs, must be non-decreasing).
- Applied management %: `=CHOOSE(MATCH(SponsorMOIC, ThresholdColumn, 1), BandPct1, BandPct2, ...)` or nested IF bands. Key on MOIC or IRR per the toggle on Cover.
- Band threshold column must be sorted ascending and start at 0.0x so MATCH with match-type 1 always lands; the top band caps the management share.
- Ratchet key cell: `=IF(RatchetBasis="MOIC", PreRatchetSponsorMOIC, PreRatchetSponsorIRR)` so one band table serves either metric.

### Exit Returns
- B2 Exit Equity Value (link from a deal model or blue input).
- Preferred/loan-note redemption: `=PrefBalance*(1+Coupon)^Years` accreted, paid first: `=MIN(ExitEquity, AccretedPref)`.
- Residual ordinary pool: `=ExitEquity - PrefPaid`.
- Management ordinary proceeds: `=ResidualOrdinary*AppliedMgmtPct`.
- Sponsor proceeds: `=PrefPaid + ResidualOrdinary*(1-AppliedMgmtPct) - SponsorOrdGivenToRatchet` (sponsor funds the ratchet dilution from its ordinary share).
- Management MOIC: `=MgmtProceeds/MgmtSweetInvested` formatted 0.0x.
- Sponsor MOIC: `=SponsorProceeds/SponsorInvested` formatted 0.0x.
- IRR each: `=XIRR({-Invested, Proceeds}, {Entry, Exit})` using dated flows.
- Circularity note: sponsor MOIC drives the ratchet, and the ratchet changes sponsor proceeds. Break it by ratcheting on the pre-ratchet sponsor MOIC, or enable iterative calc; prefer the pre-ratchet basis to keep the file deterministic.
- Pre-ratchet sponsor MOIC (ratchet key): `=(PrefPaid + ResidualOrdinary*(1-MgmtBasePct))/SponsorInvested` so the band lookup never depends on its own output.
- Value transferred to management by the ratchet: `=ResidualOrdinary*(AppliedMgmtPct-MgmtBasePct)`, shown as a line so the dilution cost to the sponsor is explicit.

### Workbook build notes
- Write the band lookup as a CHOOSE/MATCH formula string; never paste the resolved percentage.
- Add a base band starting at 0.0x so MATCH never returns #N/A below the lowest threshold.
- Use `DefinedName` for the ownership and stack named ranges so Exit Returns formulas read cleanly.

## Formula and formatting conventions
Blue font for inputs (invested amounts, rates, ratchet bands). Black for in-tab formulas. Green for cross-tab links (`CapTable!`, `MIP!`). No hardcoded numbers inside formulas; use named ranges. One consistent formula per row. Percentages 0.0%, dollars with separators, MOIC and multiples 0.0x.

## Checks
- Ownership sums to 100%: `=ROUND(SUM(Ordinary % range)-1,4)=0`.
- Proceeds reconcile: `=ROUND((MgmtProceeds+SponsorProceeds)-ExitEquity,2)=0`.
- Ratchet bands continuous and non-decreasing: `=AND(BandPct2>=BandPct1, BandPct3>=BandPct2)`.
- Pref fully redeemed before ordinary if cash allows: `=IF(ExitEquity>=AccretedPref, PrefPaid=AccretedPref, TRUE)`.
- Applied management % at least the base: `=AppliedMgmtPct>=MgmtBasePct`.
- Ratchet value transfer non-negative: `=RatchetValueToMgmt>=0`.

## Recalculate and verify
After writing, recompute headless so MATCH/CHOOSE, the accretion, and XIRR resolve. Scan for #REF!, #DIV/0!, #VALUE!, #NAME?. A frequent issue is MATCH returning #N/A when sponsor MOIC is below the lowest band; add a base band starting at 0. Recalc until clean, then deliver.

## Edge cases to handle
- Exit equity below the accreted preferred: ordinary holders get nothing; sweet equity MOIC is zero and the model must not show negative proceeds.
- Sponsor MOIC between two bands: MATCH with match-type 1 takes the lower band; confirm the band table is sorted ascending.
- Option pool funded from ordinary dilutes everyone pro rata; net the pool out of ordinary before the management base percentage is applied.

## Inputs to gather
Pro forma instruments and amounts (loan notes/preferred, sponsor ordinary, sweet equity, option pool), coupon or PIK rates, entry and exit dates, exit equity value, and the ratchet band thresholds and percentages.

## Example
Hypothetical: sponsor invests 90 (80 loan notes at 8% PIK, 10 ordinary), management 2 sweet equity, pool 8% of ordinary. At exit equity 300, loan notes accrete to about 117 and are paid first; residual ordinary 183 splits by ownership with management at the 2.5x band taking a stepped-up share. Management MOIC several times its sweet equity; sponsor MOIC about 2.5x to 3.0x.
