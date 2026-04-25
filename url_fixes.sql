-- URL fixes — run in Supabase SQL Editor
-- https://supabase.com/dashboard/project/xvdkurbfxsukyxnykssy/sql

-- ── RESOURCES TABLE ──────────────────────────────────────────────────────────

UPDATE resources
SET url = 'https://www.renaissancephilanthropy.org'
WHERE title = 'Renaissance Philanthropy';

UPDATE resources
SET url = 'https://sites.research.google/languages/'
WHERE title ILIKE '%1000 Languages%';

-- ── ORGANIZATIONS TABLE ───────────────────────────────────────────────────────

-- Kilimo: agkilimo.com → kilimo.com/en
UPDATE organizations
SET source_url = 'https://kilimo.com/en/'
WHERE name ILIKE '%Kilimo%' AND source_url ILIKE '%agkilimo%';

-- Google Malnutrition Forecast: ai.google/social-good → blog.google
UPDATE organizations
SET source_url = 'https://blog.google/outreach-initiatives/google-org/ai-collaboratives-wildfires-food-security/'
WHERE name ILIKE '%Malnutrition%';

-- Google 1000 Languages: old research URL → new
UPDATE organizations
SET source_url = 'https://sites.research.google/languages/'
WHERE source_url ILIKE '%1000languages%';

-- Alphabet X Tapestry: x.company → x.company/projects/tapestry/
UPDATE organizations
SET source_url = 'https://x.company/projects/tapestry/'
WHERE name ILIKE '%Tapestry%';

-- OCHA DEEP: deephelper.org → thedeep.io
UPDATE organizations
SET source_url = 'https://www.thedeep.io'
WHERE source_url ILIKE '%deephelper%';

-- ── DOMAIN_PANEL_ITEMS — fix broken citation URLs ─────────────────────────────

-- Kilimo source in domain panel
UPDATE domain_panel_items
SET source_url = 'https://kilimo.com/en/'
WHERE source_url ILIKE '%agkilimo%';

-- Mental health chatbot: Guardian → NPR (confirmed working)
UPDATE domain_panel_items
SET source_url = 'https://www.npr.org/sections/health-shots/2023/06/08/1180838096/an-eating-disorders-chatbot-offered-dieting-advice-raising-fears-about-ai-in-hea'
WHERE source_url ILIKE '%guardian%' AND source_url ILIKE '%eating-disorder%';

-- WHO CHW connectivity → BMC Public Health multi-country survey (confirmed)
UPDATE domain_panel_items
SET source_url = 'https://bmcpublichealth.biomedcentral.com/articles/10.1186/s12889-024-18062-3'
WHERE source_url ILIKE '%who.int%' AND domain_slug = 'health';

-- FAO precision agriculture → updated URL (redirect target)
UPDATE domain_panel_items
SET source_url = 'https://openknowledge.fao.org/handle/20.500.14283/cb9652en'
WHERE source_url ILIKE '%fao.org/documents%cb9652en%';

-- HRW asylum AI: 404 → confirmed HRW asylum page
UPDATE domain_panel_items
SET source_url = 'https://www.hrw.org/topic/refugees-and-migrants/asylum-seekers'
WHERE source_url ILIKE '%automating-cruelty%';

-- Biometric data misuse: Privacy International 404 → confirmed HRW Rohingya article
UPDATE domain_panel_items
SET source_url = 'https://www.hrw.org/news/2021/06/15/un-shared-rohingya-data-without-informed-consent'
WHERE source_url ILIKE '%privacyinternational%';

-- Google 1000 Languages in domain panel
UPDATE domain_panel_items
SET source_url = 'https://sites.research.google/languages/'
WHERE source_url ILIKE '%1000languages%';

-- Remove unverified source for Meta/Google ending programs
-- (no confirmed source found — citation removed rather than leaving broken)
UPDATE domain_panel_items
SET source_url = NULL
WHERE content ILIKE '%Meta and Google ended%';

-- Verify results
SELECT table_name, source_col, val
FROM (
  SELECT 'organizations' AS table_name, source_url AS source_col, name AS val FROM organizations
  UNION ALL
  SELECT 'resources', url, title FROM resources
  UNION ALL
  SELECT 'domain_panel_items', source_url, LEFT(content,60) FROM domain_panel_items
) t
WHERE source_col IS NOT NULL
  AND (
    source_col ILIKE '%agkilimo%'
    OR source_col ILIKE '%deephelper%'
    OR source_col ILIKE '%1000languages%'
    OR source_col ILIKE '%renaissance.org%'
    OR source_col ILIKE '%ai.google/social-good%'
    OR source_col ILIKE '%automating-cruelty%'
    OR source_col ILIKE '%privacyinternational%'
  );
