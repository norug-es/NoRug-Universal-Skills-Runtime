export type Skill={id:string;name:string;domain:string;version:string;description:string;capabilities:string[];offline:boolean;status:'stable'|'beta'|'alpha'};
const finance=['debt-schedule','dividend-discount-model','dcf-model','trading-comps','sum-of-the-parts','market-sizing','pricing-model','scenario-manager','sources-and-uses','dividend-recap-model','credit-stats-covenant','management-incentive-plan','value-creation-bridge','accretion-dilution','precedent-transactions','pe-returns-waterfall','irr-moic-calculator','revenue-build','unit-economics','three-statement-model','lbo-model','fund-model','monte-carlo','sensitivity-tables','football-field'];
const descriptions:Record<string,string>={'dcf-model':'Discounted cash flow valuation with explicit assumptions, terminal value and QA gates.','lbo-model':'Leveraged buyout model with sources & uses, debt schedule and returns.','market-sizing':'TAM/SAM/SOM sizing with transparent assumptions and uncertainty.','monte-carlo':'Monte Carlo simulation with explicit distributions and statistical validation.','three-statement-model':'Integrated income statement, balance sheet and cash flow model.'};
export const skills:Skill[]=finance.map(id=>({id:`finance.${id}`,name:id.split('-').map(x=>x[0].toUpperCase()+x.slice(1)).join(' '),domain:'finance',version:'2.1.0',description:descriptions[id]??'Portable financial modeling skill with explicit inputs, methodology and QA gates.',capabilities:[id,'financial-modeling'],offline:true,status:'beta'}));
export const platformAdapters=[
{name:'ChatGPT / OpenAI',protocols:['Remote MCP','REST','Function tools'],mode:'cloud',status:'ready-for-test'},
{name:'Claude',protocols:['Remote MCP','REST'],mode:'cloud',status:'ready-for-test'},
{name:'OpenClaw',protocols:['MCP','REST/OpenAPI'],mode:'hybrid',status:'ready-for-test'},
{name:'Manus',protocols:['MCP/Connector','REST'],mode:'cloud',status:'ready-for-test'},
{name:'Ollama',protocols:['Tool calling','REST'],mode:'local',status:'ready-for-test'}
];
