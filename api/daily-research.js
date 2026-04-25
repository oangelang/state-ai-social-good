// Workflow A: Daily Research — runs every day at 7am UTC
// Scans news sources for new AI for social good content, writes pending items to Supabase

import Anthropic from '@anthropic-ai/sdk';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY;

const NEWS_SOURCES = [
  'ssir.org',
  'technologyreview.com/topic/artificial-intelligence',
  'restofworld.org',
  'themarkup.org',
  'aiforgood.itu.int/news',
  'ainowinstitute.org',
  'hai.stanford.edu/news',
  'anthropic.com/news',
  'google.org/news',
  'data.org/news',
];

async function runResearch() {
  const client = new Anthropic({ apiKey: ANTHROPIC_KEY });

  const today = new Date().toISOString().split('T')[0];

  const prompt = `Search the following sources for new AI for social good content published in the last 24 hours (today is ${today}).

Sources to check: ${NEWS_SOURCES.join(', ')}

For each relevant item found, extract:
- headline
- source_name (publication name)
- source_url (direct article URL)
- published_date (YYYY-MM-DD)
- summary (2 sentences in your own words, no direct quotes)
- domain_tags (array from: climate, health, ocean, food, equity, education, humanitarian, energy, general)
- is_risk_related (true if about AI harms, bias, misuse, or governance failures)

Only include items that are genuinely about AI being used for social good, climate, health, education, humanitarian work, or AI governance/risk. Skip pure tech news, product launches, and opinion pieces without new evidence.

Return ONLY a valid JSON array. No markdown, no explanation. Example:
[{"headline":"...","source_name":"...","source_url":"...","published_date":"2026-04-25","summary":"...","domain_tags":["health"],"is_risk_related":false}]

If nothing relevant was published today, return an empty array: []`;

  // Run agentic loop with web search
  const messages = [{ role: 'user', content: prompt }];
  let response;

  for (let i = 0; i < 10; i++) {
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

  // Extract JSON from final response
  const textBlock = response.content.find(b => b.type === 'text');
  if (!textBlock) return [];

  const raw = textBlock.text.trim();
  const jsonStart = raw.indexOf('[');
  const jsonEnd = raw.lastIndexOf(']');
  if (jsonStart === -1) return [];

  const items = JSON.parse(raw.slice(jsonStart, jsonEnd + 1));

  // Add required fields for Supabase insert
  return items.map(item => ({
    ...item,
    status: 'pending',
    found_by: 'cowork',
  }));
}

async function writeToSupabase(items) {
  if (items.length === 0) return { count: 0 };

  const res = await fetch(`${SUPABASE_URL}/rest/v1/news`, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_SERVICE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'return=minimal',
    },
    body: JSON.stringify(items),
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Supabase insert failed: ${err}`);
  }

  return { count: items.length };
}

export default async function handler(req, res) {
  // Allow manual trigger via GET, cron fires as GET too
  try {
    const items = await runResearch();
    const result = await writeToSupabase(items);
    res.status(200).json({ ok: true, message: `Daily research complete. ${result.count} news items added.` });
  } catch (err) {
    console.error('daily-research error:', err);
    res.status(500).json({ ok: false, error: err.message });
  }
}
