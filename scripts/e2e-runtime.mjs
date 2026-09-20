const base=(process.env.SKILLS_BASE_URL||'http://127.0.0.1:3000').replace(/\/$/,'');
const key=process.env.SKILLS_GATEWAY_API_KEY||'';
async function j(path,init={}){const r=await fetch(base+path,init);let body;try{body=await r.json()}catch{body=await r.text()}return {status:r.status,body}}
function gate(name,ok,detail=''){console.log(`${name}=${ok?'PASS':'FAIL'}${detail?' '+detail:''}`);if(!ok)process.exitCode=1}
const health=await j('/api/v1/health');gate('HEALTH_GATE',health.status===200,`status=${health.status}`);
const caps=await j('/api/v1/core/capabilities');gate('CORE_DISCOVERY_GATE',caps.status===200&&Number(caps.body?.count)>0,`count=${caps.body?.count??0}`);
const tools=await j('/api/v1/adapters/ollama/tools');gate('OLLAMA_TOOL_SCHEMA_GATE',tools.status===200&&tools.body?.count===caps.body?.count,`count=${tools.body?.count??0}`);
const mcp=await j('/mcp',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({jsonrpc:'2.0',id:1,method:'tools/list',params:{}})});gate('MCP_TOOL_DISCOVERY_GATE',mcp.status===200&&Array.isArray(mcp.body?.result?.tools),`tools=${mcp.body?.result?.tools?.length??0}`);
if(caps.body?.capabilities?.length){const read=caps.body.capabilities.find(x=>!x.write&&!x.admin);if(read){const denied=await j('/api/v1/core/execute',{method:'POST',headers:{'content-type':'application/json',...(key?{'x-api-key':key}:{})},body:JSON.stringify({id:read.id,arguments:{}})});if(process.env.EXPECT_EXECUTION_DISABLED==='true')gate('EXECUTION_CLOSED_GATE',denied.status===403,`status=${denied.status}`)}}
