# v2.5 production launch checklist

## Billing
- Create Stripe Products/recurring Prices for Plus, Pro and Business in USD.
- Set `STRIPE_PRICE_PLUS`, `STRIPE_PRICE_PRO`, `STRIPE_PRICE_BUSINESS`.
- Configure signed webhook URL: `https://skills.norug.es/api/v1/billing/stripe/webhook`.
- Enable Stripe customer portal cancellation/payment-method management.
- Test checkout, renewal, failed payment, cancellation and duplicate webhook delivery in Stripe test mode.

## Stablecoin
- Start with an allowlisted small set of routes; Base/Polygon USDC is operationally simpler than enabling every chain on day one.
- Confirm token contract/mint and decimals independently before adding each route.
- Treasury private keys must never be present in the Skills container.
- Use dedicated treasury addresses where possible and protect treasury operations outside the runtime.
- Configure RPC endpoints server-side and confirmation requirements.
- Test wrong token, wrong network, wrong sender, wrong amount, duplicate tx, expired intent and insufficient confirmations.
- Review accounting, invoicing, tax and compliance treatment before enabling mainnet payments.

## Quotas
- Run `004_billing_subscriptions_crypto.sql`.
- Verify Free receives 50 credits and quota returns HTTP 402 after exhaustion.
- Verify only successful Core calls consume credits.
- Verify token creation stops at each plan limit.

## Dokploy
- Add all Stripe and stablecoin secrets in Dokploy, never source control.
- Deploy with `SWAT_EXECUTION_ENABLED=false` first.
- Run migrations.
- Verify `/Pricing`, registration/login, Stripe test checkout and dashboard.
- Enable read execution, test usage ledger, then enable production billing.

## Gates required before public launch
`NEXT_BUILD=PASS`, `POSTGRES_MIGRATIONS_E2E=PASS`, `STRIPE_TESTMODE_E2E=PASS`, `STRIPE_WEBHOOK_IDEMPOTENCY=PASS`, `CRYPTO_TESTNET_E2E=PASS`, `QUOTA_E2E=PASS`, `DOKPLOY_E2E=PASS`.


## v2.6 credit commerce additions
Apply `db/migrations/005_usage_credit_commerce.sql`. Configure `USAGE_ALERT_EMAILS=true` if SMTP usage alerts should be sent. Optional one-time Stripe Price IDs: `STRIPE_TOPUP_100`, `STRIPE_TOPUP_500`, `STRIPE_TOPUP_2000`, `STRIPE_TOPUP_10000`; if omitted, checkout builds server-side `price_data` from the database pack. Validate 80/90/100% UX, 402 enforcement, concurrent reservations, Stripe Test Mode top-up, and crypto testnet top-up before production.
