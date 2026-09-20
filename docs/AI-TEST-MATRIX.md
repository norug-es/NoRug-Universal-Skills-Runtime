# AI interoperability test matrix

The alpha validates protocol discovery first. End-to-end execution is gated for v2.1+.

| Platform | Adapter target | Alpha test | Execution target |
|---|---|---|---|
| ChatGPT | MCP / REST | `tools/list`, `skills_resolve` | v2.1 |
| Claude | MCP | `initialize`, `tools/list`, `tools/call` | v2.1 |
| OpenClaw | MCP / REST | discovery + resolver | v2.1 |
| Manus | MCP / REST | discovery + resolver | v2.1 |
| Ollama | REST/function adapter | resolver contract | v2.1 |

## Required PASS gates

- Endpoint reachable over TLS.
- No anonymous arbitrary execution.
- Registry result deterministic for the same version.
- Resolver returns a registered skill only.
- MCP error responses are valid JSON-RPC objects.
- Platform adapter records runtime/model/version during execution once execution is enabled.
