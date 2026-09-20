# Architecture

AI clients never own NoRug methodology. They consume capabilities through adapters.

```text
ChatGPT | Claude | OpenClaw | Manus | Ollama
                    |
             MCP / REST / SDK
                    |
            NoRug Skills Gateway
                    |
      Registry + Resolver + Policies
                    |
       Skill Execution Engine (next)
                    |
      Evidence + QA + Provenance
```

## Separation of concerns

1. **Skill** — methodology, inputs, outputs, dependencies and QA contract.
2. **Adapter** — translates a platform's tool/function interface to NoRug APIs.
3. **Resolver** — maps intent to capabilities/skills.
4. **Execution** — invokes allowed tools and produces evidence-backed outputs.
5. **Provenance** — records skill version/hash, runtime, model, tools and evidence.
