# SWAT Core integration contract

Canonical source: `https://bitcoiners.norug.es/openapi.json`.

The Skills Runtime does **not** maintain a handwritten copy of SWAT endpoints. `lib/swat-openapi.ts` fetches the live OpenAPI contract, hashes it with SHA-256, traverses every HTTP operation under `paths`, and converts every operation into a `CoreCapability`.

## Coverage invariant
For a given OpenAPI document:

`capability_count == number of HTTP operations in paths`

No tag or method is excluded from discovery. This includes System, Bitcoin, Mining, Risk, Fiscal, Cases & reports, OSINT, Meteora and Administration, plus future tags that appear later.

## Stable capability identifiers
A deterministic identifier is generated from the first tag, HTTP method and path, for example:

`swat.bitcoin.post.btc_tx_analyze`

Clients should persist both capability id and `contract_sha256` with evidence so a run can be traced to the exact upstream contract version.

## Authentication boundary
AI client → `SKILLS_GATEWAY_API_KEY` → Skills Runtime → `SWAT_CORE_API_KEY` → SWAT Core.

The Core key is never returned to a client and never needs to be configured in ChatGPT, Claude, OpenClaw, Manus or Ollama.

## Execution policy
- `SWAT_EXECUTION_ENABLED=false`: discovery only.
- `SWAT_EXECUTION_ENABLED=true`, writes/admin false: read execution only.
- `SWAT_ALLOW_WRITES=true`: permits non-admin write operations.
- `SWAT_ALLOW_ADMIN=true`: permits administration operations. Keep disabled outside isolated authorized tests.

OpenAPI inclusion and permission are intentionally separate concepts.
