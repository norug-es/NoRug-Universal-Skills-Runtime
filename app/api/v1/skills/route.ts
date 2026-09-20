import {skills} from '@/data/registry';import {recordEvent} from '@/lib/telemetry';
export async function GET(req:Request){await recordEvent(req,{route:'/api/v1/skills',action:'skills_list',status_code:200,metadata:{count:skills.length}});return Response.json({count:skills.length,skills})}
