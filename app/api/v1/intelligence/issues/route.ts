import {adminAuthorized} from '@/lib/admin-auth';import {intelligenceSummary} from '@/lib/observability';
export async function GET(req:Request){if(!adminAuthorized(req))return Response.json({error:'unauthorized'},{status:401});const hours=Math.min(24*30,Math.max(1,Number(new URL(req.url).searchParams.get('hours')||24)));return Response.json(await intelligenceSummary(hours))}
