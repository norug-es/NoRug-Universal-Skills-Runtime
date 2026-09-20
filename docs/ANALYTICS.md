# Gateway Analytics, Audit & Sponsor Attribution — v2.3

The runtime records product analytics and operational audit events in PostgreSQL. It is designed to support both internal gateway intelligence and sanitized investor/customer reporting.

## Event model
Each event can retain: timestamp, request ID, pseudonymous principal/session/API-key/IP hashes, user agent, country when supplied by the reverse proxy, channel, AI provider/model, route/action, skill, capability, HTTP method, status, outcome, latency, write/admin flags, extracted blockchain entities, and metadata.

Raw prompt/query text is **off by default**. Enable only with `TELEMETRY_STORE_QUERY_TEXT=true`. Query hashes and structured blockchain entities are still available for deduplication/analysis without retaining full text.

## Internal dashboard
`/Dashboard` is protected by `DASHBOARD_ADMIN_KEY` and shows provider/model usage, top blockchain entities, service/capability usage, errors, latency, and recent traces.

## Public/VC dashboard
`/Stats` exposes aggregate calls, unique users, sessions, daily traction, peak hours, and most-used services. It never exposes raw prompts, addresses, transaction hashes, IP-derived identifiers, or individual traces.

## Database
Apply `db/migrations/001_gateway_telemetry.sql` to the PostgreSQL database selected by `DATABASE_URL`, or run `npm run db:migrate` during a controlled deployment step.

## Privacy boundary
- Do not expose internal entity analytics publicly.
- IP addresses are never stored raw by this implementation.
- User/API/session identifiers are salted hashes.
- Rotate `TELEMETRY_HASH_SALT` only deliberately: changing it breaks longitudinal identity continuity.

## User identity accuracy
For accurate cross-platform user counts, clients should send a stable opaque `x-norug-user-id` (preferred) or `x-client-id`. The gateway hashes it before storage. If absent, analytics falls back to API-key/IP/user-agent signals, which measure a principal rather than a guaranteed human user. Never send an email, wallet, or other direct personal identifier as `x-norug-user-id`; use an application-generated opaque UUID.


## Sponsor / referral attribution
Sponsor attribution is first-touch by default and is stored independently from the gateway event stream. A sponsor can own multiple campaign codes. Referral codes may arrive through `/r/<code>`, the `nr_ref` cookie, `x-norug-referral-code`, or `x-sponsor-code`.

Internal analytics can correlate pseudonymous referred principals with sessions, calls, services, AI providers and blockchain entities. Sponsor-facing analytics expose only aggregate metrics for that sponsor.

Tables: `sponsors`, `sponsor_campaigns`, `referral_attributions`, plus denormalized sponsor/campaign keys on `gateway_events`. Apply `002_sponsors_referrals.sql` after the base telemetry migration.
