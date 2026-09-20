# v2.3-alpha1 — Sponsor & Referral Attribution

Adds sponsor/referral attribution to Gateway Intelligence.

## Included
- Sponsor master records and status.
- Multiple campaigns per sponsor.
- `/r/<code>` referral links with 90-day `nr_ref` cookie.
- API/MCP attribution headers (`x-norug-referral-code`, `x-sponsor-code`).
- Immutable first-touch attribution by default.
- Sponsor/campaign keys propagated into every telemetry event.
- Internal sponsor management at `/Dashboard/Sponsors`.
- Sponsor-facing aggregate portal at `/Sponsor`.
- Optional consented lead profile endpoint.
- Sponsor metrics: referred principals, active users, sessions, calls, campaign performance, top services.
- ES/EN/PT documentation updated.

## Security / privacy
- Referral users remain pseudonymous by default.
- Contact profiles require explicit `marketing_consent=true`.
- Sponsor portal does not expose user-level PII, raw prompts, wallets or other sponsors.
- Portal token is generated once at sponsor creation and stored only as a hash.

## Validation
- Registry check: PASS.
- Runtime inventory / sponsor schema check: PASS.
- Next production build: NOT VERIFIED in this artifact environment.
- PostgreSQL + Dokploy E2E: NOT RUN.
