// Workflow B: Weekly Validation — runs every Sunday at 8am UTC
// Validates existing published orgs/resources, archives past events

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

async function runValidation(items, type) {
  const client = new Anthropic({ apiKey: ANTHROPIC_KEY });

  const isOrg = type === 'organizations';
  const prompt = isOrg
    ? `For each organization below, check if it is still active and accurately described.

1. Visit the source_url — does it still work? (not 404, not redirected to homepage)
2. Search for the org name + "2025 OR 2026" — any news about program ending, shutdown, or changed focus?
3. Does the description still match what they actually do?

Organizations:
${JSON.stringify(items, null, 2)}

Return ONLY valid JSON array, no markdown:
[{"id":"...","name":"...","verdict":"valid","notes":"...","suggested_update":null}]

verdict must be one of: valid, update_needed, stale, check_manually`
    : `For each resource below, check if it is still active and the URL still works.

1. Visit the URL — does it return a live page? (not 404, not dead)
2. For newsletters/podcasts: search for recent issues from 2025-2026
3. For reports: has newer research superseded it?

Resources:
${JSON.stringify(items, null, 2)}

Return ONLY valid JSON array, no markdown:
[{"id":"...","title":"...","verdict":"valid","notes":"...","replacement_url":null}]

verdict must be one of: valid, outdated, dead_link, superseded, check_manually`;

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

  const textBlock = response.content.find(b => b.type === 'text');
  if (!textBlock) return [];
  const raw = textBlock.text.trim();
  const jsonStart = raw.indexOf('[');
  const jsonEnd = raw.lastIndexOf(']');
  if (jsonStart === -1) return [];
  return JSON.parse(raw.slice(jsonStart, jsonEnd + 1));
}

async function archivePastEvents() {
  // Move past events to rejected so they stop showing
  await supabaseFetch(
    `/events?event_date=lt.${new Date().toISOString().split('T')[0]}&status=eq.published`,
    { method: 'PATCH', body: JSON.stringify({ status: 'rejected' }) }
  );
}

async function flagItem(table, id, notes, nameField) {
  await supabaseFetch(`/${table}?id=eq.${id}`, {
    method: 'PATCH',
    body: JSON.stringify({
      status: 'pending',
      added_by: 'cowork-validation',
      [nameField === 'title' ? 'description' : 'ai_use_case']: `VALIDATION NOTE (${new Date().toISOString().split('T')[0]}): ${notes}`,
    }),
  });
}

export default async function handler(req, res) {
  const results = { orgs: {}, resources: {}, events_archived: 0 };

  try {
    // Archive past events
    await archivePastEvents();
    results.events_archived = 1;

    // Pull and validate orgs (batch of 20 to stay within context limits)
    const orgs = await supabaseFetch(
      '/organizations?status=eq.published&select=id,name,source_url,ai_use_case,evidence_tier&limit=20'
    );
    const orgResults = await runValidation(orgs, 'organizations');
    results.orgs = { total: orgs.length, flagged: 0 };
    for (const r of orgResults) {
      if (['update_needed', 'stale', 'check_manually'].includes(r.verdict)) {
        await flagItem('organizations', r.id, r.notes, 'name');
        results.orgs.flagged++;
      }
    }

    // Pull and validate resources
    const resources = await supabaseFetch(
      '/resources?status=eq.published&select=id,title,url,resource_type&limit=20'
    );
    const resourceResults = await runValidation(resources, 'resources');
    results.resources = { total: resources.length, flagged: 0 };
    for (const r of resourceResults) {
      if (['outdated', 'dead_link', 'superseded', 'check_manually'].includes(r.verdict)) {
        await flagItem('resources', r.id, r.notes, 'title');
        results.resources.flagged++;
      }
    }

    res.status(200).json({ ok: true, message: 'Weekly validation complete.', results });
  } catch (err) {
    console.error('weekly-validation error:', err);
    res.status(500).json({ ok: false, error: err.message, results });
  }
}
