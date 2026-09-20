# Deployment

Production target: Dokploy-managed Docker Compose on the NoRug VPS.

Use `docs/DOKPLOY.md` as the canonical deployment runbook. Public routing is owned by Dokploy Domains/Traefik and targets service `skills`, port `3000`.

Do not add host port bindings or `container_name`. Keep runtime secrets in Dokploy Environment. Start with all execution gates disabled and promote only after E2E discovery/security tests pass.
