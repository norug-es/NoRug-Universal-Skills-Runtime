import {recordEvent} from '@/lib/telemetry';
export async function POST(req:Request){const b=await req.json().catch(()=>({}));await recordEvent(req,{route:String(b.route||'/'),action:String(b.action||'pageview'),channel:String(b.channel||'ui'),provider:String(b.provider||'browser'),status_code:200,metadata:b.metadata||{}});return Response.json({ok:true})}
