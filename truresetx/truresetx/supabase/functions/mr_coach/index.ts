import { createClient } from "@supabase/supabase-js";

export default async (req: Request) => {
  try {
    const payload = await req.json();
    const { record, table } = payload as any;
    if (!record || !table) return new Response('ok');

    const supabase = createClient(
        (globalThis as any).Deno?.env.get('SUPABASE_URL') ?? (globalThis as any).process?.env?.SUPABASE_URL ?? '',
        (globalThis as any).Deno?.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? (globalThis as any).process?.env?.SUPABASE_SERVICE_ROLE_KEY ?? ''
    );
    const userId = record.user_id as string;

    const recs: Array<{title:string,body:string,action:any}> = [];

    if (table === 'mr_events') {
      if (record.kind === 'love_failure') {
        recs.push({ title: 'Heartbreak Grounding', body: '2‑min breath + 5‑4‑3‑2‑1 now.', action:{ route:'/mr/grounding/heartbreak' }});
        recs.push({ title: 'No‑Contact Timer', body: 'Activate 24‑hr no‑contact and journal.', action:{ route:'/mr/no-contact/start' }});
      }
      if (record.kind === 'debt_pressure') {
        recs.push({ title: 'Calm Agent Call', body: 'Read the script. Schedule a call in 24–48h.', action:{ route:'/mr/agent-call/script' }});
        recs.push({ title: 'Finance Action 1', body: 'List 3 dues + 1 micro payment.', action:{ route:'/mr/finance/action' }});
      }
      if (record.kind === 'boss_harassment') {
        recs.push({ title: 'Boss Debrief', body: 'Log facts → effects → asks.', action:{ route:'/mr/boss/debrief' }});
      }
      if (record.kind === 'anger_surge') {
        recs.push({ title: 'Anger Reset', body: 'Count‑down + breath + release now.', action:{ route:'/mr/anger/reset' }});
      }
    }

    for (const r of recs) {
      await supabase.from('mw_recommendations').insert({ user_id: userId, category:'general', title: r.title, body: r.body, action: r.action });
    }

    return new Response('ok');
  } catch (err) {
    console.error('mr_coach error', err);
    return new Response('error', { status: 500 });
  }
};
