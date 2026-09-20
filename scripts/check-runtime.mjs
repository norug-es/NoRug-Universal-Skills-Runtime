import fs from 'node:fs';
const must=[
 'app/mcp/route.ts','app/api/v1/core/capabilities/route.ts','app/api/v1/core/execute/route.ts',
 'app/api/v1/adapters/ollama/tools/route.ts','app/api/v1/adapters/openai/tools/route.ts',
 'app/api/v1/admin/sponsors/route.ts','app/api/v1/referrals/attribute/route.ts','app/api/v1/referrals/profile/route.ts',
 'app/api/v1/sponsor/summary/route.ts','app/r/[code]/route.ts','app/Dashboard/Sponsors/page.tsx','app/Sponsor/page.tsx',
 'db/migrations/001_gateway_telemetry.sql','db/migrations/002_sponsors_referrals.sql','docs/SPONSORS.md',
 'docker-compose.yml','.env.example','docs/DOKPLOY.md','docs/PROVIDER-TESTS.md'
];
let ok=true;for(const f of must){if(!fs.existsSync(f)){console.error('MISSING',f);ok=false}else console.log('PASS',f)}
const compose=fs.readFileSync('docker-compose.yml','utf8');
for(const bad of ['container_name:','127.0.0.1:3088'])if(compose.includes(bad)){console.error('FORBIDDEN',bad);ok=false}
if(!compose.includes('expose:')){console.error('MISSING expose');ok=false}
const migration=fs.readFileSync('db/migrations/002_sponsors_referrals.sql','utf8');
for(const token of ['CREATE TABLE IF NOT EXISTS sponsors','CREATE TABLE IF NOT EXISTS sponsor_campaigns','CREATE TABLE IF NOT EXISTS referral_attributions','CREATE TABLE IF NOT EXISTS referral_leads','sponsor_id','campaign_id'])if(!migration.includes(token)){console.error('SPONSOR_SCHEMA_MISSING',token);ok=false}
const telemetry=fs.readFileSync('lib/telemetry.ts','utf8');
if(!telemetry.includes('ensureFirstTouchAttribution')){console.error('ATTRIBUTION_NOT_WIRED');ok=false}else console.log('PASS first-touch attribution wired into telemetry');
process.exit(ok?0:1);
