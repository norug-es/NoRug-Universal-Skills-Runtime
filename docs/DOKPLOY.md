# Dokploy deployment — skills.norug.es

## Target
Deploy `NoRug Universal Skills Runtime v2.1` as a Docker Compose service managed by Dokploy.

## Dokploy service
1. Create/open the NoRug project in Dokploy.
2. Add a **Docker Compose** service from the Git repository.
3. Compose path: `./docker-compose.yml`.
4. Configure the environment variables from `.env.example` in Dokploy.
5. Deploy.
6. In **Domains**, add `skills.norug.es` to service `skills`, container port `3000`, HTTPS enabled.

Do not set `container_name`. Do not publish the application port to the host. The compose file uses `expose: 3000`; Dokploy/Traefik owns public routing.

## Required secrets
- `SKILLS_GATEWAY_API_KEY`: long random key protecting executable gateway calls.
- `SWAT_CORE_API_KEY`: SWAT Core API key used server-side for protected Core endpoints.

Never expose `SWAT_CORE_API_KEY` to browsers or AI clients. AI clients authenticate to the Skills Gateway; the gateway authenticates upstream to SWAT Core.

## Safe rollout sequence
Start with:
```
SWAT_EXECUTION_ENABLED=false
SWAT_ALLOW_WRITES=false
SWAT_ALLOW_ADMIN=false
```
Validate discovery, OpenAPI import and MCP `tools/list`. Then enable read execution:
```
SWAT_EXECUTION_ENABLED=true
SWAT_ALLOW_WRITES=false
SWAT_ALLOW_ADMIN=false
```
Only enable writes/admin for isolated tests after explicit review.

## Health URLs
- `/api/v1/health`
- `/api/v1/runtime/info`
- `/api/v1/core/capabilities`

## Rollback
Keep the previous Dokploy deployment. If E2E fails, roll back the application artifact; do not modify SWAT Core.

## v2.2 telemetry database
Use a PostgreSQL database reachable from the skills container and add these Dokploy secrets:

```env
DATABASE_URL=postgresql://...
DB_SSL=false
TELEMETRY_HASH_SALT=<long-random-secret>
TELEMETRY_STORE_QUERY_TEXT=false
DASHBOARD_ADMIN_KEY=<long-random-secret>
```

Apply migrations once before enabling production traffic:

```bash
npm run db:migrate
```

Do not publish the PostgreSQL port. Keep it on the Dokploy/internal network or use a managed private endpoint.


## v2.6 credit commerce additions
Apply `db/migrations/005_usage_credit_commerce.sql`. Configure `USAGE_ALERT_EMAILS=true` if SMTP usage alerts should be sent. Optional one-time Stripe Price IDs: `STRIPE_TOPUP_100`, `STRIPE_TOPUP_500`, `STRIPE_TOPUP_2000`, `STRIPE_TOPUP_10000`; if omitted, checkout builds server-side `price_data` from the database pack. Validate 80/90/100% UX, 402 enforcement, concurrent reservations, Stripe Test Mode top-up, and crypto testnet top-up before production.
