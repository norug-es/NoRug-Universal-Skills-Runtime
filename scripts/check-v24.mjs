import fs from 'node:fs';
const must=[
'db/migrations/003_identity_tokens_observability.sql','lib/user-auth.ts','lib/observability.ts','lib/email.ts',
'app/api/v1/auth/register/route.ts','app/api/v1/auth/login/route.ts','app/api/v1/auth/forgot-password/route.ts','app/api/v1/auth/reset-password/route.ts',
'app/api/v1/auth/tokens/route.ts','app/api/v1/account/activity/route.ts','app/api/v1/observability/events/route.ts','app/api/v1/intelligence/issues/route.ts',
'app/Account/page.tsx','app/Dashboard/Intelligence/page.tsx','docs/IDENTITY-AND-TOKENS.md','docs/RUNTIME-INTELLIGENCE.md'];
let bad=0;for(const f of must){if(!fs.existsSync(f)){console.error('MISSING='+f);bad++}}
const mig=fs.readFileSync('db/migrations/003_identity_tokens_observability.sql','utf8');for(const t of ['app_users','user_sessions','user_api_tokens','password_reset_tokens','runtime_events','auth_rate_limits'])if(!mig.includes(t)){console.error('MISSING_TABLE='+t);bad++}
const compose=fs.readFileSync('docker-compose.yml','utf8');for(const k of ['AUTH_PEPPER','SMTP_HOST','OBSERVABILITY_INGEST_KEY'])if(!compose.includes(k)){console.error('MISSING_ENV='+k);bad++}
console.log(`V24_IDENTITY_OBSERVABILITY_GATE=${bad?'FAIL':'PASS'}`);process.exit(bad?1:0);
