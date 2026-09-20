import {adminAuthorized} from '@/lib/admin-auth';import {internalSummary} from '@/lib/telemetry';
export async function GET(req:Request){if(!adminAuthorized(req))return Response.json({error:'unauthorized'},{status:401});const d=Math.min(365,Math.max(1,Number(new URL(req.url).searchParams.get('days')||30)));return Response.json(await internalSummary(d))}
