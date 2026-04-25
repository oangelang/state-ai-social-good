// Workflow C: Monthly Deep Audit — runs 1st of each month at 9am UTC
// Audits domain panel items for accuracy; surfaces new org candidates

import Anthropic from '@anthropic-ai/sdk';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY;

const HEADERS = {
  apikey: SUPABASE_SERVICE_KEY,
  Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
  'Content-Type': 'application/json',
};

async function supabaseFetch(path, options = {}) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1${path}`, {
    headers: HEADERS,
    ...options,
  });
  if (!res.ok) throw new Error(`Supabase ${options.method || 'GET'} ${path} failed: ${await res.text()}`);
  return options.method && options.method !== 'GET' ? null : res.json();
}

async function askClaude(prompt) {
  const client = new Anthropic({ apiKey: ANTHROPIC_KEY });
  const messages = [{ role: 'user', content: prompt }];
  let response;

  for (let i = 0; i < 15; i++) {
    response = await client.messages.create({
      model: 'claude-opus-4-7',
      max_tokens: 4000,
      tools: [{ type: 'web_search_20250305', name: 'web_search' }],
      messages,
    });

    if (response.stop_reason === 'end_turn') break;

    if (response.stop_reason === 'tool_use') {
      messages.push({ role: 'assistant', content: response.content });
      const toolResults = response.content
        .filter(b => b.type === 'tool_use')
        .map(b => ({ type: 'tool_result', tool_use_id: b.id, content: b.input?.result ?? '' }));
      messages.push({ role: 'user', content: toolResults });
    }
  }

  return response.content.find(b => b.type === 'text')?.text ?? '';
}

function parseJSON(text) {
  const start = text.indexOf('[');
  const end = text.lastIndexOf(']');
  if (start === -1) return [];
  try { return JSON.parse(text.slice(start, end + 1)); } catch { return []; }
}

export default async function handler(req, res) {
  const today = new Date().toISOString().split('T')[0];
  const report = {};

  try {
    // C1 — Audit domain panel items (tried + caution columns)
    const panelItems = await supabaseFetch(
      '/domain_panel_items?status=eq.published&column_type=neq.open&select=id,domain_slug,column_type,org_name,content,source_url&limit=60'
    );

    const auditText = await askClaude(`You are reviewing field intelligence items for a website about AI for social good. Today is ${today}.

For each item below, search for recent evidence (2025-2026) that would:
- Contradict or update a "tried" claim (program ended, impact figures changed, org shut down)
- Change a "caution" (problem addressed, or new failure makes it more serious)

Also flag any "tried" items where the source_url appears to be dead (404).

Items:
${JSON.stringify(panelItems, null, 2)}

Return ONLY valid JSON array, no markdown:
[{"id":"...","domain_slug":"...","column_type":"tried","current_content":"...","verdict":"current","notes":"...","suggested_revision":null}]

verdict must be one of: current, update_needed, outdated`);

    const auditResults = parseJSON(auditText);
    report.panel_items = { total: panelItems.length, flagged: 0 };

    for (const r of auditResults) {
      if (['update_needed', 'outdated'].includes(r.verdict)) {
        await supabaseFetch(`/domain_panel_items?id=eq.${r.id}`, {
          method: 'PATCH',
          body: JSON.stringify({
            status: 'pending',
            content: `${r.current_content} | AUDIT NOTE (${today}): ${r.notes}${r.suggested_revision ? ` | SUGGESTED: ${r.suggested_revision}` : ''}`,
          }),
        });
        report.panel_items.flagged++;
      }
    }

    // C2 — Find new org candidates
    const newOrgText = await askClaude(`Search for organizations that have launched or gained attention in the last 30 days for using AI for social good (today is ${today}).

Focus on:
- New deployments (not just announcements or press releases)
- Organizations working in underrepresented domains: ocean, energy, humanitarian
- NYC-based organizations
- Organizations in the Global South

Search: "AI for social good" launched OR deployed 2026, site:restofworld.org AI 2026, site:ssir.org AI 2026

Return ONLY valid JSON array, no markdown:
[{"name":"...","url":"...","domain":"...","description":"...","evidence_tier":"deployed"}]

evidence_tier must be one of: deployed, pilot, research

Return empty array [] if nothing found.`);

    const newOrgs = parseJSON(newOrgText);
    report.new_org_candidates = newOrgs.length;

    // Write new org candidates as pending submissions for review
    if (newOrgs.length > 0) {
      const submissions = newOrgs.map(org => ({
        submission_type: 'organization',
        submitted_data: org,
        status: 'pending',
        added_by: 'cowork-monthly',
      }));
      await fetch(`${SUPABASE_URL}/rest/v1/submissions`, {
        method: 'POST',
        headers: { ...HEADERS, Prefer: 'return=minimal' },
        body: JSON.stringify(submissions),
      });
    }

    res.status(200).json({
      ok: true,
      message: `Monthly audit complete. ${report.panel_items?.flagged ?? 0} panel items flagged, ${report.new_org_candidates} new org candidates queued for review.`,
      report,
    });
  } catch (err) {
    console.error('monthly-audit error:', err);
    res.status(500).json({ ok: false, error: err.message, report });
  }
}
