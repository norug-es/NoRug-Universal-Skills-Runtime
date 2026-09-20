# NoRug Universal Skills Runtime v2.6

Provider-neutral skill and capability gateway for `skills.norug.es`.

NoRug Universal Skills Runtime es un gateway provider-neutral que permite descubrir, describir y ejecutar habilidades (skills) para skills.norug.es. Integra:

Sistema de atribución de patrocinadores y referidos con tracking de primer toque.
25 habilidades financieras portables.
Importación dinámica de operaciones SWAT Core desde OpenAPI.
Endpoint MCP remoto y REST gateway para descubrimiento y ejecución de capacidades.
Exportación de herramientas compatibles con OpenAI y Ollama.
Autenticación mediante API key, monetización con planes de suscripción (Stripe) y sistema de créditos.
Despliegue con Docker/Dokploy y almacenamiento en PostgreSQL.
Soporte inicial para interoperabilidad con ChatGPT/OpenAI, Claude, OpenClaw, Manus y Ollama. Documentación en ES/EN/PT.


## What is integrated
- Sponsor/referral attribution with first-touch tracking, campaigns, sponsor portal and consented lead profiles.
- 25 portable Finance skills from v2.
- Dynamic 100% import of SWAT Core HTTP operations from `https://bitcoiners.norug.es/openapi.json`.
- Remote MCP endpoint at `/mcp`.
- REST gateway for capability discovery, description and policy-gated execution.
- OpenAI-compatible function-tool export.
- Ollama tool-calling export.
- Initial interoperability target: ChatGPT/OpenAI, Claude, OpenClaw, Manus and Ollama.
- ES/EN/PT docs at `/Docs/es`, `/Docs/en`, `/Docs/pt`.
- Dokploy-first Docker Compose deployment.

## Trust boundary
Clients authenticate to Skills Runtime with `SKILLS_GATEWAY_API_KEY`. Only the server stores `SWAT_CORE_API_KEY`. Discovery is complete; execution is deny-by-default.

## Deploy with Dokploy
1. Add this repository as a Docker Compose service.
2. Compose path: `./docker-compose.yml`.
3. Add variables from `.env.example` in Dokploy Environment.
4. Deploy.
5. Add `skills.norug.es` in Dokploy Domains → service `skills` → port `3085` → HTTPS.
6. Keep execution disabled for initial discovery tests.
7. Run `SKILLS_BASE_URL=https://skills.norug.es EXPECT_EXECUTION_DISABLED=true node scripts/e2e-runtime.mjs`.

See `docs/DOKPLOY.md`, `docs/CORE-INTEGRATION.md` and `docs/PROVIDER-TESTS.md`.

## API
- `GET /api/v1/health`
- `GET /api/v1/runtime/info`
- `GET /api/v1/skills`
- `POST /api/v1/resolve`
- `GET /api/v1/core/capabilities`
- `POST /api/v1/core/describe`
- `POST /api/v1/core/execute`
- `GET /api/v1/adapters/openai/tools`
- `GET /api/v1/adapters/ollama/tools`
- `GET /api/v1/openapi.json`
- `POST /mcp`

## Release gates
```bash
npm run check:registry
npm run check:runtime
npm run build
```
The production build must pass in CI/Dokploy before production promotion.

## v2.2 Gateway Intelligence
The prototype now includes first-party PostgreSQL telemetry, a ChatGPT/Claude-style test console (`/`), sanitized public traction metrics (`/Stats`) and an authenticated internal dashboard (`/Dashboard`). See `docs/ANALYTICS.md`.


## v2.3 Sponsor & Referral Attribution
- First-touch sponsor attribution through `/r/<code>`, cookies or API/MCP headers.
- Sponsor master records, campaigns and portal tokens.
- Internal sponsor management at `/Dashboard/Sponsors`.
- Sponsor-facing aggregate dashboard at `/Sponsor`.
- Per-sponsor referred users, sessions, calls, top services and campaign performance.
- Referral attribution is joined into the gateway telemetry stream without exposing sponsor data publicly.


## v2.5 Identity, Personal Tokens & Runtime Intelligence
- Account registration with optional sponsor/campaign code.
- Email/password login with HttpOnly sessions.
- Email password recovery via SMTP with single-use 30-minute reset tokens.
- Personal `nru_...` connection tokens: multiple per user, hashed at rest, individually revocable.
- `/Account` personal dashboard: calls, sessions, errors, services, blockchain entities, recent activity and token management.
- `/api/v1/observability/events` cross-service warning/error ingest.
- `/Dashboard/Intelligence` internal issue clustering and deterministic remediation suggestions.
- Auth rate limiting backed by PostgreSQL.
- Runtime messages are redacted for common secret patterns before persistence.

See `docs/IDENTITY-AND-TOKENS.md` and `docs/RUNTIME-INTELLIGENCE.md`.


## v2.5 Monetization

Launch billing adds Free, Plus, Pro and Business plans with monthly credit quotas enforced in the gateway. Stripe handles recurring card subscriptions through Checkout + Billing Portal + signed webhooks. Direct stablecoin checkout supports configured USDC/USDT routes as non-custodial-to-the-gateway, 30-day prepaid access: the runtime only publishes a configured treasury address and verifies the submitted on-chain transfer before activating the plan. The application never needs a treasury private key.

Launch defaults are configurable in `subscription_plans`: Free 50 credits, Plus $19/500, Pro $79/2,500, Business $299/15,000. Treat these as launch defaults, not immutable pricing.

Do not enable stablecoin checkout until treasury addresses, token contracts/mints, RPC endpoints, accounting and applicable compliance requirements have been reviewed.

## v2.6 Usage & Credit Commerce

v2.6 closes the quota lifecycle. Monthly plan credits are consumed first; separately purchased credits are consumed afterwards and default to 365-day validity. PostgreSQL-backed request reservations prevent concurrent calls from overspending the same balance. Usage milestones are recorded once per billing period at 50%, 80%, 90% and 100%; optional email alerts are enabled with `USAGE_ALERT_EMAILS=true`.

When no spendable credits remain, `/api/v1/core/execute` returns `402 quota_exceeded` with current usage and renewal information. `/Account` and `/Credits` offer immediate Stripe or configured USDC/USDT top-ups plus plan upgrade. Default credit packs are 100/$5, 500/$20, 2,000/$60 and 10,000/$250; all pack economics are data-driven in PostgreSQL.

See `docs/USAGE-CREDIT-COMMERCE.md` and `docs/RELEASE-v2.6-alpha1.md`.
