-- NoRug Universal Skills Runtime v2.5 — billing, quotas, Stripe and stablecoin receipts
CREATE TABLE IF NOT EXISTS subscription_plans (
  code text PRIMARY KEY,
  name text NOT NULL,
  monthly_price_cents integer NOT NULL DEFAULT 0 CHECK(monthly_price_cents >= 0),
  currency text NOT NULL DEFAULT 'usd',
  monthly_credits integer NOT NULL CHECK(monthly_credits >= 0),
  max_personal_tokens integer NOT NULL DEFAULT 1 CHECK(max_personal_tokens >= 0),
  rpm_limit integer NOT NULL DEFAULT 10 CHECK(rpm_limit > 0),
  history_days integer NOT NULL DEFAULT 30 CHECK(history_days > 0),
  seats integer NOT NULL DEFAULT 1 CHECK(seats > 0),
  sort_order integer NOT NULL DEFAULT 0,
  active boolean NOT NULL DEFAULT true,
  features jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
INSERT INTO subscription_plans(code,name,monthly_price_cents,monthly_credits,max_personal_tokens,rpm_limit,history_days,seats,sort_order,features) VALUES
('free','Free',0,50,1,10,7,1,10,'["50 monthly credits","1 personal connection token","7-day activity history","Community access"]'),
('plus','Plus',1900,500,5,60,90,1,20,'["500 monthly credits","5 personal connection tokens","90-day history","Priority gateway access"]'),
('pro','Pro',7900,2500,20,180,365,1,30,'["2,500 monthly credits","20 personal connection tokens","365-day history","Advanced SWAT usage","Priority support"]'),
('business','Business',29900,15000,100,600,730,1,40,'["15,000 monthly credits","100 connection tokens","730-day history","Exportable analytics","Priority onboarding","Priority support"]')
ON CONFLICT(code) DO UPDATE SET name=excluded.name,monthly_price_cents=excluded.monthly_price_cents,monthly_credits=excluded.monthly_credits,max_personal_tokens=excluded.max_personal_tokens,rpm_limit=excluded.rpm_limit,history_days=excluded.history_days,seats=excluded.seats,sort_order=excluded.sort_order,features=excluded.features,updated_at=now();

ALTER TABLE app_users ADD COLUMN IF NOT EXISTS stripe_customer_id text;
CREATE UNIQUE INDEX IF NOT EXISTS ux_app_users_stripe_customer ON app_users(stripe_customer_id) WHERE stripe_customer_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS user_subscriptions (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  plan_code text NOT NULL REFERENCES subscription_plans(code),
  provider text NOT NULL CHECK(provider IN ('free','stripe','crypto','admin')),
  provider_customer_id text,
  provider_subscription_id text,
  status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','trialing','past_due','canceled','expired','incomplete')),
  current_period_start timestamptz NOT NULL,
  current_period_end timestamptz NOT NULL,
  cancel_at_period_end boolean NOT NULL DEFAULT false,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_user_subscriptions_user_period ON user_subscriptions(user_id,current_period_end DESC);
CREATE UNIQUE INDEX IF NOT EXISTS ux_user_subscription_provider_id ON user_subscriptions(provider,provider_subscription_id) WHERE provider_subscription_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS usage_ledger (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  request_id text,
  capability_id text,
  credits integer NOT NULL CHECK(credits > 0),
  occurred_at timestamptz NOT NULL DEFAULT now(),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS ix_usage_ledger_user_time ON usage_ledger(user_id,occurred_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS ux_usage_ledger_request ON usage_ledger(user_id,request_id) WHERE request_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS billing_events (
  id uuid PRIMARY KEY,
  provider text NOT NULL,
  provider_event_id text NOT NULL,
  event_type text NOT NULL,
  user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  processed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(provider,provider_event_id)
);

CREATE TABLE IF NOT EXISTS crypto_payment_intents (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  plan_code text NOT NULL REFERENCES subscription_plans(code),
  asset text NOT NULL CHECK(asset IN ('USDC','USDT')),
  network text NOT NULL,
  amount_atomic numeric(78,0) NOT NULL,
  amount_display numeric(30,8) NOT NULL,
  treasury_address text NOT NULL,
  expected_payer_address text NOT NULL,
  token_address text NOT NULL,
  decimals integer NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','submitted','confirmed','expired','rejected')),
  tx_hash text,
  expires_at timestamptz NOT NULL,
  confirmed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS ix_crypto_intents_user ON crypto_payment_intents(user_id,created_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS ux_crypto_intents_tx ON crypto_payment_intents(network,tx_hash) WHERE tx_hash IS NOT NULL;

CREATE TABLE IF NOT EXISTS crypto_payment_receipts (
  id uuid PRIMARY KEY,
  intent_id uuid NOT NULL UNIQUE REFERENCES crypto_payment_intents(id) ON DELETE CASCADE,
  network text NOT NULL,
  tx_hash text NOT NULL,
  block_ref text,
  payer_address text,
  treasury_address text NOT NULL,
  asset text NOT NULL,
  amount_atomic numeric(78,0) NOT NULL,
  verification_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  verified_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(network,tx_hash)
);

-- Free entitlements are created lazily by the billing runtime for existing and new users.
