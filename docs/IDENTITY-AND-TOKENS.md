# Identity, sponsor attribution and personal tokens

## Registration
Users register with email/password and may provide a sponsor or campaign code. Referral attribution is first-touch and is attached to both the account and gateway telemetry.

## Sessions
Web login creates an opaque HttpOnly session token stored only as a SHA-256 hash in PostgreSQL. Sessions are revocable and expire after `AUTH_SESSION_DAYS`.

## Personal connection tokens
Authenticated users can create multiple `nru_...` personal tokens from `/Account`. Only the hash is persisted. The clear token is returned once. Each client (ChatGPT, Claude, OpenClaw, Ollama, custom software) should use a separate token so it can be revoked independently.

Send it as:

```http
Authorization: Bearer nru_...
```

## Password recovery
`POST /api/v1/auth/forgot-password` returns the same response whether or not the account exists. Valid accounts receive a 30-minute single-use reset link by SMTP. Resetting the password revokes all existing web sessions.

## Personal dashboard
`/Account` shows only that user's calls, sessions, errors, services, blockchain entities extracted from their calls, recent activity, and personal tokens.
