---
name: accretion-dilution
version: 1.0.0-chatgpt
domain: transactions
portable: true
dependencies: [sources-and-uses, scenario-manager, sensitivity-tables]
triggers: ["accretion dilution", "pro forma eps", "merger eps"]
description: Builds an M&A accretion/dilution .xlsx from scratch with live formulas across separate inputs/calculations/outputs tabs plus checks, computing pro forma EPS, accretion/(dilution) %, breakeven synergies, and a premium-by-mix sensitivity table. Use when someone wants a downloadable merger EPS impact model.
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


# Accretion/Dilution

## When to use
Use when the user wants a new merger model that tests whether a deal raises or lowers the acquirer's earnings per share, given a consideration mix of cash, stock, and new debt, plus synergies. It solves pro forma EPS, the accretion/(dilution) percentage, the breakeven synergies, and a sensitivity table over premium and payment mix. This skill builds a downloadable .xlsx using ChatGPT spreadsheet tooling. It should produce a standalone workbook without requiring an Excel add-in.

## What it builds
Tabs: Cover (legend), Assumptions (blue inputs for both companies and the deal), Deal Structure (offer value, consideration mix, new shares, financing), Combined EPS (pro forma net income and EPS bridge), Sensitivity (premium x cash/stock mix to accretion), Checks. Inputs live only on Assumptions.

## Build workflow
1. Create the six tabs.
2. On Assumptions, enter acquirer and target standalone net income, shares, and share prices, plus offer premium, cash/stock/new-debt mix percentages, new debt rate, cash interest forgone rate, tax rate, and synergies. Name key ranges.
3. Build Deal Structure: offer price per share, offer equity value, dollar split across cash/stock/debt, and new shares issued.
4. Build Combined EPS: pro forma net income with after-tax adjustments, pro forma shares, pro forma EPS, and accretion/(dilution) %.
5. Add the breakeven synergies solve.
6. Build the Sensitivity data table (premium x mix to accretion %).
7. Wire Checks; apply formatting and the cover legend.
8. Recalculate the workbook headless.
9. Verify zero formula errors and that shares and net income tie, then deliver the .xlsx.

## Tab-by-tab spec
Single-period deal math (one column) unless a multi-year EPS bridge is requested. One consistent formula per line.

Deal Structure
- Offer price per share: `=Assumptions!TargetPrice*(1+Assumptions!PremiumPct)`.
- Offer equity value: `=OfferPricePerShare*Assumptions!TargetShares`.
- Cash consideration: `=OfferEquityValue*Assumptions!CashPct`; stock: `=OfferEquityValue*Assumptions!StockPct`; new debt: `=OfferEquityValue*Assumptions!DebtPct`. The three percentages should sum to 100.0%.
- New acquirer shares issued: `=StockConsideration/Assumptions!AcquirerPrice`.
- New debt raised: `=DebtConsideration`; cash used: `=CashConsideration`.

Combined EPS
- Pro forma net income: `=Assumptions!AcquirerNI + Assumptions!TargetNI + AfterTaxSynergies - AfterTaxNewInterest - AfterTaxForegoneInterest`.
  - After-tax synergies: `=Assumptions!Synergies*(1-Assumptions!TaxRate)`.
  - After-tax new interest: `=NewDebtRaised*Assumptions!NewDebtRate*(1-Assumptions!TaxRate)`.
  - After-tax foregone interest on cash used: `=CashUsed*Assumptions!CashYield*(1-Assumptions!TaxRate)`.
- Pro forma shares: `=Assumptions!AcquirerShares + NewSharesIssued`.
- Pro forma EPS: `=ProFormaNI/ProFormaShares`.
- Acquirer standalone EPS: `=Assumptions!AcquirerNI/Assumptions!AcquirerShares`.
- Accretion/(dilution) %: `=ProFormaEPS/StandaloneEPS-1`; label: `=IF(AccretionPct>=0,"Accretion","Dilution")`.

Breakeven synergies
- Synergies that set accretion to zero: solve `=StandaloneEPS*ProFormaShares - (AcquirerNI + TargetNI - AfterTaxNewInterest - AfterTaxForegoneInterest)` then gross up by `(1-TaxRate)`; present as the required pre-tax synergy amount.

Sensitivity
- Two-variable Data Table: row input = premium %, column input = cash % of mix, result cell `=CombinedEPS!AccretionPct`. Build with Excel data-table (TABLE) structure or as a grid of accretion formulas keyed to scenario inputs.

## Formula and formatting conventions
Blue = inputs (Assumptions/Cover only). Black = in-tab formulas. Green = cross-tab links. Never hardcode a constant inside a formula; reference Assumptions. One consistent formula per line item. $mm for dollars, EPS to two decimals (`0.00`), shares in mm, accretion/(dilution) and percentages to one decimal (`0.0%`), negatives in parentheses.

## Checks
- Mix percentages sum to 100.0%: `=Assumptions!CashPct+StockPct+DebtPct=1`.
- Pro forma shares = acquirer shares + new shares issued (recompute as a tie).
- Pro forma net income reconciles to the sum of components (independent re-add).
- Accretion sign labeled correctly: positive shows "Accretion," negative shows "Dilution."
- Master PASS/FAIL flag via IF over the check rows.

## Recalculate and verify
the workbook writer may not evaluate every Excel formula immediately, so EPS and accretion cells are blank until recalculated. No structural circularity here, but watch for `#DIV/0!` if shares or price inputs are zero; guard divisors. Recalculate with a supported spreadsheet calculation engine when available, then scan for `#REF!`, `#DIV/0!`, `#VALUE!`, `#NAME?`; fix in a loop until zero errors and all ties hold before delivering.

## Inputs to gather
Acquirer and target net income, share count, and share price; offer premium; cash/stock/new-debt mix; new debt rate; yield on cash used; tax rate; and expected synergies (pre-tax).

## Example
Hypothetical: acquirer net income 200.0 on 100.0 shares (EPS 2.00); target net income 60.0, target price 20.0, 40.0 shares; premium 25.0% gives offer price 25.00 and equity value 1000.0; mix 50.0% cash / 50.0% stock; new shares 500.0/AcquirerPrice 50.00 = 10.0; tax 25.0%; synergies 20.0. Pro forma EPS lands near 2.10, roughly 5.0% accretion.
