CREATE TABLE IF NOT EXISTS gateway_events (
  id BIGSERIAL PRIMARY KEY,
  event_id TEXT NOT NULL UNIQUE,
  request_id TEXT NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  principal_hash TEXT NOT NULL,
  session_hash TEXT NOT NULL,
  api_key_hash TEXT,
  ip_hash TEXT,
  user_agent TEXT,
  country TEXT,
  channel TEXT NOT NULL DEFAULT 'rest',
  provider TEXT NOT NULL DEFAULT 'unknown',
  model TEXT,
  route TEXT NOT NULL,
  action TEXT NOT NULL,
  skill_id TEXT,
  capability_id TEXT,
  http_method TEXT,
  status_code INTEGER,
  outcome TEXT NOT NULL DEFAULT 'ok',
  latency_ms INTEGER,
  write_operation BOOLEAN NOT NULL DEFAULT false,
  admin_operation BOOLEAN NOT NULL DEFAULT false,
  query_text TEXT,
  query_hash TEXT,
  entities JSONB NOT NULL DEFAULT '[]'::jsonb,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS gateway_events_occurred_idx ON gateway_events(occurred_at DESC);
CREATE INDEX IF NOT EXISTS gateway_events_principal_idx ON gateway_events(principal_hash,occurred_at DESC);
CREATE INDEX IF NOT EXISTS gateway_events_session_idx ON gateway_events(session_hash,occurred_at DESC);
CREATE INDEX IF NOT EXISTS gateway_events_capability_idx ON gateway_events(capability_id,occurred_at DESC);
CREATE INDEX IF NOT EXISTS gateway_events_skill_idx ON gateway_events(skill_id,occurred_at DESC);
CREATE INDEX IF NOT EXISTS gateway_events_provider_idx ON gateway_events(provider,occurred_at DESC);
CREATE INDEX IF NOT EXISTS gateway_events_entities_gin ON gateway_events USING gin(entities);
