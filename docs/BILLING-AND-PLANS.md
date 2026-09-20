# Billing and plans — v2.5

## Launch plans

| Plan | USD / month | Included credits | Personal tokens | History |
|---|---:|---:|---:|---:|
| Free | 0 | 50 | 1 | 7 days |
| Plus | 19 | 500 | 5 | 90 days |
| Pro | 79 | 2,500 | 20 | 365 days |
| Business | 299 | 15,000 | 100 | 730 days |

These are launch defaults and live in `subscription_plans`, so they can be changed without rewriting quota logic.

## Credits

The public UI can call them included queries, but enforcement uses weighted credits. Lightweight read/discovery calls cost 1; analytical/forensic/trace operations default to 5; writes 10; administration 20. Only successful SWAT executions are charged.

## Stripe

Required secrets: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, and one Stripe recurring Price ID per paid plan. Configure the webhook to `/api/v1/billing/stripe/webhook`. The webhook is signature-verified and provider event IDs are idempotent in `billing_events`.

## USDC / USDT

The direct crypto path is prepaid, not an auto-pull subscription. A user creates a 60-minute payment intent, sends the exact stablecoin amount to the configured treasury address, declares the sending wallet, receives a slightly unique atomic invoice amount, submits the transaction hash/signature, and receives 30 days only after token, network, sender, treasury destination and exact amount verify on-chain. The gateway never signs or sends funds and should never hold treasury private keys.

Routes are configured through `STABLECOIN_PAYMENT_CONFIG_JSON`; do not hardcode mainnet token addresses in application logic.

Example shape:

```json
[
  {
    "network":"base",
    "kind":"evm",
    "rpc_url":"https://...",
    "asset":"USDC",
    "token_address":"0x...",
    "treasury_address":"0x...",
    "decimals":6,
    "confirmations":3
  },
  {
    "network":"solana",
    "kind":"solana",
    "rpc_url":"https://...",
    "asset":"USDT",
    "token_address":"mint...",
    "treasury_address":"owner-wallet...",
    "decimals":6
  }
]
```
