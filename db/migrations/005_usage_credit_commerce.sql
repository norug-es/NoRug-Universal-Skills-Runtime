-- NoRug Universal Skills Runtime v2.6 — reservations, top-ups, milestones and commerce analytics
CREATE TABLE IF NOT EXISTS credit_packs (
  code text PRIMARY KEY,
  name text NOT NULL,
  credits integer NOT NULL CHECK(credits > 0),
  price_cents integer NOT NULL CHECK(price_cents > 0),
  currency text NOT NULL DEFAULT 'usd',
  validity_days integer NOT NULL DEFAULT 365 CHECK(validity_days > 0),
  sort_order integer NOT NULL DEFAULT 0,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
INSERT INTO credit_packs(code,name,credits,price_cents,validity_days,sort_order) VALUES
('credits_100','100 credits',100,500,365,10),
('credits_500','500 credits',500,2000,365,20),
('credits_2000','2,000 credits',2000,6000,365,30),
('credits_10000','10,000 credits',10000,25000,365,40)
ON CONFLICT(code) DO UPDATE SET name=excluded.name,credits=excluded.credits,price_cents=excluded.price_cents,validity_days=excluded.validity_days,sort_order=excluded.sort_order,updated_at=now();

CREATE TABLE IF NOT EXISTS credit_grants (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  pack_code text REFERENCES credit_packs(code),
  credits_total integer NOT NULL CHECK(credits_total > 0),
  credits_remaining integer NOT NULL CHECK(credits_remaining >= 0),
  provider text NOT NULL CHECK(provider IN ('stripe','crypto','admin','promo')),
  provider_reference text,
  status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','exhausted','expired','revoked')),
  expires_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(provider,provider_reference)
);
CREATE INDEX IF NOT EXISTS ix_credit_grants_user_fifo ON credit_grants(user_id,status,expires_at,created_at);

ALTER TABLE usage_ledger ADD COLUMN IF NOT EXISTS monthly_credits integer NOT NULL DEFAULT 0 CHECK(monthly_credits >= 0);
ALTER TABLE usage_ledger ADD COLUMN IF NOT EXISTS topup_credits integer NOT NULL DEFAULT 0 CHECK(topup_credits >= 0);
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='usage_credit_split_check') THEN ALTER TABLE usage_ledger ADD CONSTRAINT usage_credit_split_check CHECK(monthly_credits + topup_credits = credits) NOT VALID; END IF; END $$;

CREATE TABLE IF NOT EXISTS credit_grant_consumptions (
  id uuid PRIMARY KEY,
  usage_id uuid NOT NULL REFERENCES usage_ledger(id) ON DELETE CASCADE,
  grant_id uuid NOT NULL REFERENCES credit_grants(id) ON DELETE RESTRICT,
  credits integer NOT NULL CHECK(credits > 0),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_credit_grant_consumptions_grant ON credit_grant_consumptions(grant_id);

CREATE TABLE IF NOT EXISTS credit_reservations (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  request_id text NOT NULL,
  capability_id text,
  credits integer NOT NULL CHECK(credits > 0),
  status text NOT NULL DEFAULT 'reserved' CHECK(status IN ('reserved','consumed','released','expired')),
  expires_at timestamptz NOT NULL DEFAULT now()+interval '10 minutes',
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id,request_id)
);
CREATE INDEX IF NOT EXISTS ix_credit_reservations_user_status ON credit_reservations(user_id,status,expires_at);

CREATE TABLE IF NOT EXISTS usage_notifications (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  period_start timestamptz NOT NULL,
  period_end timestamptz NOT NULL,
  threshold integer NOT NULL CHECK(threshold IN (50,80,90,100)),
  plan_code text NOT NULL,
  used_credits integer NOT NULL,
  monthly_credits integer NOT NULL,
  channel text NOT NULL DEFAULT 'in_app',
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id,period_start,threshold)
);
CREATE INDEX IF NOT EXISTS ix_usage_notifications_user ON usage_notifications(user_id,created_at DESC);

ALTER TABLE crypto_payment_intents ALTER COLUMN plan_code DROP NOT NULL;
ALTER TABLE crypto_payment_intents ADD COLUMN IF NOT EXISTS purchase_type text NOT NULL DEFAULT 'plan' CHECK(purchase_type IN ('plan','topup'));
ALTER TABLE crypto_payment_intents ADD COLUMN IF NOT EXISTS credit_pack_code text REFERENCES credit_packs(code);

CREATE TABLE IF NOT EXISTS commerce_events (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES app_users(id) ON DELETE SET NULL,
  event_type text NOT NULL,
  plan_code text,
  pack_code text,
  provider text,
  amount_cents integer,
  credits integer,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  occurred_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_commerce_events_time ON commerce_events(occurred_at DESC);
CREATE INDEX IF NOT EXISTS ix_commerce_events_type ON commerce_events(event_type,occurred_at DESC);
