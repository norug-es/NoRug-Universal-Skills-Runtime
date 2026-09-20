import {publicSummary} from '@/lib/telemetry';
export async function GET(req:Request){const d=Math.min(365,Math.max(1,Number(new URL(req.url).searchParams.get('days')||30)));return Response.json(await publicSummary(d))}
