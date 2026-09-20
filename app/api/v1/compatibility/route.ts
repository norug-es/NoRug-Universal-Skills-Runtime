import {platformAdapters} from "@/data/registry";
export async function GET(){return Response.json({runtime:"2.2.0-alpha.1",protocols:["MCP JSON-RPC MVP","REST/JSON"],platforms:platformAdapters})}
