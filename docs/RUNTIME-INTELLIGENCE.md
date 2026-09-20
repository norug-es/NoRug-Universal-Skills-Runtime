# Runtime Intelligence

Runtime Intelligence collects structured `debug`, `info`, `warning`, `error`, and `fatal` events from the Skills Gateway and any external service that forwards events to:

`POST /api/v1/observability/events`

Authenticate with `x-observability-key: $OBSERVABILITY_INGEST_KEY`.

The internal dashboard `/Dashboard/Intelligence` groups warnings/errors by deterministic fingerprint and reports occurrence count, first/last seen, service/component, status, latency and a rule-based remediation suggestion.

This is not full-environment observability unless each service/container forwards its events. SWAT Core, workers, n8n workflows and other containers should progressively send structured events or be connected through a log collector adapter.

The initial recommendation engine is intentionally deterministic. An AI analyst can be added later as a second layer, but recommendations should always cite the underlying event evidence.
