# AI provider interoperability tests

Canonical remote MCP endpoint: `https://skills.norug.es/mcp`
REST/OpenAPI descriptor: `https://skills.norug.es/api/v1/openapi.json`

## Test contract
Every provider must prove:
1. Connection succeeds.
2. Tool discovery returns NoRug built-ins and every current SWAT Core OpenAPI operation.
3. A public/read-only Core call succeeds.
4. A protected read call succeeds when gateway credentials are supplied.
5. A write/admin call is denied while its policy gate is disabled.
6. The same natural-language task selects equivalent capability IDs across providers.
7. No upstream SWAT API key is revealed to the provider.

## ChatGPT / OpenAI
Use the public remote MCP URL with the OpenAI MCP tool/server connection flow. Configure gateway authentication for executable calls. Expected state: READY_FOR_EXTERNAL_TEST.

## Claude
Connect the remote MCP endpoint through Claude's MCP connector/client. Restrict tools if desired. Expected state: READY_FOR_EXTERNAL_TEST.

## OpenClaw
Recommended remote configuration:
```
openclaw mcp add norug-skills \
  --url https://skills.norug.es/mcp \
  --transport streamable-http
openclaw mcp doctor norug-skills --probe
```
Add an Authorization header / secret using the OpenClaw secret/config mechanism before execution tests. Expected state: READY_FOR_EXTERNAL_TEST.

## Manus
Add `https://skills.norug.es/mcp` as an MCP connector and configure authentication. Expected state: READY_FOR_EXTERNAL_TEST.

## Ollama
Fetch tool definitions from:
`GET /api/v1/adapters/ollama/tools`
Pass the returned tools into Ollama chat/tool-calling requests. When Ollama requests a tool, call `/api/v1/core/execute` with the selected capability id and arguments through the local adapter/client. Expected state: READY_FOR_EXTERNAL_TEST.

## Evidence to retain
For every provider run record: provider, model, runtime version, SWAT OpenAPI SHA-256, capability id, HTTP/MCP status, policy gate result, response hash, timestamp.
