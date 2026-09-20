# Skill Router

Load the narrowest matching skill first. If the request is composite, load its dependencies only as required.

| Intent | Primary skill | Typical dependencies |
|---|---|---|
| Integrated P&L / BS / CF forecast | `three-statement-model` | revenue, debt, scenarios |
| Intrinsic company valuation | `dcf-model` | revenue, scenarios, sensitivities |
| Public-company relative valuation | `trading-comps` | — |
| Deal precedent valuation | `precedent-transactions` | — |
| Multi-segment valuation | `sum-of-the-parts` | DCF/comps |
| Valuation range visualization | `football-field` | valuation outputs |
| Leveraged buyout | `lbo-model` | sources & uses, debt, IRR/MOIC, scenarios, sensitivities |
| Debt / interest / amortization | `debt-schedule` | — |
| Credit ratios / covenant headroom | `credit-stats-covenant` | debt schedule |
| Merger EPS impact | `accretion-dilution` | sources & uses, scenarios, sensitivities |
| PE return metric | `irr-moic-calculator` | — |
| PE waterfall / carry | `pe-returns-waterfall` | IRR/MOIC |
| Management equity / ratchet | `management-incentive-plan` | waterfall, IRR/MOIC |
| Dividend recap | `dividend-recap-model` | debt, IRR/MOIC |
| Deal returns attribution | `value-creation-bridge` | IRR/MOIC |
| Fund-level economics | `fund-model` | IRR/MOIC, waterfall |
| Driver-based sales / ARR | `revenue-build` | scenarios |
| CAC/LTV/contribution economics | `unit-economics` | scenarios |
| TAM/SAM/SOM | `market-sizing` | scenarios |
| Pricing architecture | `pricing-model` | unit economics, scenarios |
| Base/Bull/Bear orchestration | `scenario-manager` | — |
| One/two-variable what-if | `sensitivity-tables` | — |
| Probabilistic uncertainty | `monte-carlo` | — |
| Dividend-based valuation | `dividend-discount-model` | scenarios, sensitivities |
| Transaction funding bridge | `sources-and-uses` | — |

## Routing rules
- If the user names a skill explicitly, prioritize it.
- For LBO, do not silently collapse debt, sources/uses, and returns logic into one opaque sheet. Compose them.
- For DCF, do not use Monte Carlo unless uncertainty/distribution analysis is requested.
- For real-company work, distinguish historical actuals, sourced market data, assumptions, and model outputs.
- If a task is purely explanatory and no workbook is requested, apply the methodology without forcing artifact creation.
