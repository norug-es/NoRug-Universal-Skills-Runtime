import {NextResponse} from 'next/server';
import {resolveReferral} from '@/lib/referrals';
export async function GET(req:Request,{params}:{params:Promise<{code:string}>}){const {code}=await params;const ref=await resolveReferral(code);const target=new URL('/',req.url);if(!ref){target.searchParams.set('ref_error','unknown');return NextResponse.redirect(target)}const res=NextResponse.redirect(target);res.cookies.set('nr_ref',code.toLowerCase(),{httpOnly:false,secure:true,sameSite:'lax',path:'/',maxAge:60*60*24*90});return res}
