CREATE TABLE IF NOT EXISTS sponsors (
  id BIGSERIAL PRIMARY KEY,
  sponsor_code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  organization TEXT,
  contact_name TEXT,
  contact_email TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','paused','disabled')),
  portal_token_hash TEXT,
  notes TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sponsor_campaigns (
  id BIGSERIAL PRIMARY KEY,
  sponsor_id BIGINT NOT NULL REFERENCES sponsors(id) ON DELETE CASCADE,
  campaign_code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','paused','disabled')),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS referral_attributions (
  id BIGSERIAL PRIMARY KEY,
  principal_hash TEXT NOT NULL,
  sponsor_id BIGINT NOT NULL REFERENCES sponsors(id) ON DELETE RESTRICT,
  campaign_id BIGINT REFERENCES sponsor_campaigns(id) ON DELETE SET NULL,
  referral_code TEXT NOT NULL,
  attribution_model TEXT NOT NULL DEFAULT 'first_touch',
  source TEXT NOT NULL DEFAULT 'link',
  landing_path TEXT,
  first_request_id TEXT,
  attributed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  UNIQUE(principal_hash)
);

ALTER TABLE gateway_events ADD COLUMN IF NOT EXISTS sponsor_id BIGINT REFERENCES sponsors(id) ON DELETE SET NULL;
ALTER TABLE gateway_events ADD COLUMN IF NOT EXISTS campaign_id BIGINT REFERENCES sponsor_campaigns(id) ON DELETE SET NULL;
ALTER TABLE gateway_events ADD COLUMN IF NOT EXISTS referral_code TEXT;

CREATE INDEX IF NOT EXISTS sponsors_code_idx ON sponsors(sponsor_code);
CREATE INDEX IF NOT EXISTS sponsor_campaigns_sponsor_idx ON sponsor_campaigns(sponsor_id, created_at DESC);
CREATE INDEX IF NOT EXISTS referral_attributions_sponsor_idx ON referral_attributions(sponsor_id, attributed_at DESC);
CREATE INDEX IF NOT EXISTS referral_attributions_campaign_idx ON referral_attributions(campaign_id, attributed_at DESC);
CREATE INDEX IF NOT EXISTS gateway_events_sponsor_idx ON gateway_events(sponsor_id, occurred_at DESC);
CREATE INDEX IF NOT EXISTS gateway_events_campaign_idx ON gateway_events(campaign_id, occurred_at DESC);

CREATE TABLE IF NOT EXISTS referral_leads (
  principal_hash TEXT PRIMARY KEY,
  display_name TEXT,
  email TEXT,
  company TEXT,
  marketing_consent BOOLEAN NOT NULL DEFAULT false,
  consent_at TIMESTAMPTZ,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS referral_leads_consent_idx ON referral_leads(marketing_consent, updated_at DESC);
