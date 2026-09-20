CREATE TABLE IF NOT EXISTS app_users (
  id UUID PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  email_normalized TEXT NOT NULL UNIQUE,
  display_name TEXT,
  company TEXT,
  password_salt TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  email_verified_at TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','disabled','locked')),
  sponsor_id BIGINT REFERENCES sponsors(id) ON DELETE SET NULL,
  campaign_id BIGINT REFERENCES sponsor_campaigns(id) ON DELETE SET NULL,
  referral_code TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_login_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS app_users_sponsor_idx ON app_users(sponsor_id, created_at DESC);

CREATE TABLE IF NOT EXISTS user_sessions (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL,
  last_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  ip_hash TEXT,
  user_agent TEXT,
  revoked_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS user_sessions_user_idx ON user_sessions(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS user_sessions_expiry_idx ON user_sessions(expires_at) WHERE revoked_at IS NULL;

CREATE TABLE IF NOT EXISTS user_api_tokens (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  token_prefix TEXT NOT NULL,
  token_hash TEXT NOT NULL UNIQUE,
  label TEXT NOT NULL DEFAULT 'default',
  scopes TEXT[] NOT NULL DEFAULT ARRAY['skills:read','skills:execute']::TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_used_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  revoked_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS user_api_tokens_user_idx ON user_api_tokens(user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS password_reset_tokens_expiry_idx ON password_reset_tokens(expires_at) WHERE used_at IS NULL;

ALTER TABLE gateway_events ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES app_users(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS gateway_events_user_idx ON gateway_events(user_id, occurred_at DESC);

CREATE TABLE IF NOT EXISTS runtime_events (
  id BIGSERIAL PRIMARY KEY,
  event_id UUID NOT NULL UNIQUE,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  source TEXT NOT NULL,
  environment TEXT NOT NULL DEFAULT 'production',
  service TEXT,
  component TEXT,
  severity TEXT NOT NULL CHECK (severity IN ('debug','info','warning','error','fatal')),
  error_code TEXT,
  message TEXT,
  message_hash TEXT,
  request_id TEXT,
  user_id UUID REFERENCES app_users(id) ON DELETE SET NULL,
  sponsor_id BIGINT REFERENCES sponsors(id) ON DELETE SET NULL,
  capability_id TEXT,
  skill_id TEXT,
  status_code INTEGER,
  latency_ms DOUBLE PRECISION,
  fingerprint TEXT,
  stack_hash TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS runtime_events_time_idx ON runtime_events(occurred_at DESC);
CREATE INDEX IF NOT EXISTS runtime_events_severity_idx ON runtime_events(severity, occurred_at DESC);
CREATE INDEX IF NOT EXISTS runtime_events_fingerprint_idx ON runtime_events(fingerprint, occurred_at DESC);
CREATE INDEX IF NOT EXISTS runtime_events_source_idx ON runtime_events(source, occurred_at DESC);

CREATE TABLE IF NOT EXISTS intelligence_findings (
  id UUID PRIMARY KEY,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  window_minutes INTEGER NOT NULL,
  fingerprint TEXT NOT NULL,
  severity TEXT NOT NULL,
  title TEXT NOT NULL,
  evidence JSONB NOT NULL DEFAULT '{}'::jsonb,
  recommendation TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','acknowledged','resolved','ignored')),
  first_seen_at TIMESTAMPTZ,
  last_seen_at TIMESTAMPTZ,
  UNIQUE(fingerprint, generated_at)
);
CREATE INDEX IF NOT EXISTS intelligence_findings_status_idx ON intelligence_findings(status, generated_at DESC);

CREATE TABLE IF NOT EXISTS auth_rate_limits (
  bucket_hash TEXT PRIMARY KEY,
  window_started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  attempts INTEGER NOT NULL DEFAULT 0
);
