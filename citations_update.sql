-- Add source_url citations to caution + open question items in domain_panel_items
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/xvdkurbfxsukyxnykssy/sql

-- ── CLIMATE ──────────────────────────────────────────────────────────────────

UPDATE domain_panel_items SET source_url = 'https://www.nature.com/articles/s41586-024-07145-1'
WHERE domain_slug = 'climate' AND column_type = 'caution'
  AND content ILIKE '%1% of global watersheds%';

UPDATE domain_panel_items SET source_url = 'https://www.theguardian.com/environment/2023/jan/18/revealed-forest-carbon-offsets-biggest-provider-worthless-verra-aoe'
WHERE domain_slug = 'climate' AND column_type = 'caution'
  AND content ILIKE '%carbon credit%';

UPDATE domain_panel_items SET source_url = 'https://www.climatechange.ai/papers'
WHERE domain_slug = 'climate' AND column_type = 'caution'
  AND content ILIKE '%adaptation%poorest%';

UPDATE domain_panel_items SET source_url = 'https://www.theguardian.com/technology/2024/feb/01/google-ai-climate-change'
WHERE domain_slug = 'climate' AND column_type = 'caution'
  AND content ILIKE '%Meta and Google ended%';

-- ── HEALTH ───────────────────────────────────────────────────────────────────

UPDATE domain_panel_items SET source_url = 'https://www.science.org/doi/10.1126/science.aax2342'
WHERE domain_slug = 'health' AND column_type = 'caution'
  AND content ILIKE '%Western data%Sub-Saharan%';

UPDATE domain_panel_items SET source_url = 'https://www.theguardian.com/technology/2023/may/31/eating-disorder-chatbot-suspended-harmful-advice'
WHERE domain_slug = 'health' AND column_type = 'caution'
  AND content ILIKE '%mental health chatbot%';

UPDATE domain_panel_items SET source_url = 'https://www.who.int/publications/i/item/9789240041929'
WHERE domain_slug = 'health' AND column_type = 'caution'
  AND content ILIKE '%connectivity%community health workers%';

-- ── OCEAN ────────────────────────────────────────────────────────────────────

UPDATE domain_panel_items SET source_url = 'https://globalfishingwatch.org/research/'
WHERE domain_slug = 'ocean' AND column_type = 'caution'
  AND content ILIKE '%Enforcement depends entirely on political will%';

UPDATE domain_panel_items SET source_url = 'https://www.coris.noaa.gov/monitoring/'
WHERE domain_slug = 'ocean' AND column_type = 'caution'
  AND content ILIKE '%Coral reef monitoring%baseline data%';

UPDATE domain_panel_items SET source_url = 'https://www.science.org/doi/10.1126/science.abo7095'
WHERE domain_slug = 'ocean' AND column_type = 'caution'
  AND content ILIKE '%Marine carbon removal%';

-- ── FOOD ─────────────────────────────────────────────────────────────────────

UPDATE domain_panel_items SET source_url = 'https://www.fao.org/documents/card/en/c/cb9652en'
WHERE domain_slug = 'food' AND column_type = 'caution'
  AND content ILIKE '%large-scale commercial farms%Smallholders%';

UPDATE domain_panel_items SET source_url = 'https://www.cgiar.org/news-events/news/new-report-agricultural-digital-technologies-are-largely-failing-smallholder-farmers/'
WHERE domain_slug = 'food' AND column_type = 'caution'
  AND content ILIKE '%Localization%local languages%';

-- ── EQUITY ───────────────────────────────────────────────────────────────────

UPDATE domain_panel_items SET source_url = 'https://www.propublica.org/article/machine-bias-risk-assessments-in-criminal-sentencing'
WHERE domain_slug = 'equity' AND column_type = 'caution'
  AND content ILIKE '%racial bias%debiasing%Historical training%';

UPDATE domain_panel_items SET source_url = 'https://www.nber.org/papers/w33078'
WHERE domain_slug = 'equity' AND column_type = 'caution'
  AND content ILIKE '%Microfinance%credit scoring%rural women%';

-- ── EDUCATION ────────────────────────────────────────────────────────────────

UPDATE domain_panel_items SET source_url = 'https://www.povertyactionlab.org/page/education-technology'
WHERE domain_slug = 'education' AND column_type = 'caution'
  AND content ILIKE '%pilots%grants end%Sustainability%structural failure%';

UPDATE domain_panel_items SET source_url = 'https://unesdoc.unesco.org/ark:/48223/pf0000380699'
WHERE domain_slug = 'education' AND column_type = 'caution'
  AND content ILIKE '%low-bandwidth%fail silently%';

-- ── HUMANITARIAN ─────────────────────────────────────────────────────────────

UPDATE domain_panel_items SET source_url = 'https://www.hrw.org/report/2024/09/12/automating-cruelty/how-ai-enabled-systems-endanger-people-seeking-asylum'
WHERE domain_slug = 'humanitarian' AND column_type = 'caution'
  AND content ILIKE '%asylum%due process%';

UPDATE domain_panel_items SET source_url = 'https://privacyinternational.org/report/4067/un-refugee-agency-shares-rohingya-data-without-consent'
WHERE domain_slug = 'humanitarian' AND column_type = 'caution'
  AND content ILIKE '%Biometric data%state actors%';

-- ── ENERGY ───────────────────────────────────────────────────────────────────

UPDATE domain_panel_items SET source_url = 'https://www.iea.org/reports/electricity-2024'
WHERE domain_slug = 'energy' AND column_type = 'caution'
  AND content ILIKE '%data centers%electricity%2028%';

UPDATE domain_panel_items SET source_url = 'https://www.iea.org/reports/sdg7-data-and-projections'
WHERE domain_slug = 'energy' AND column_type = 'caution'
  AND content ILIKE '%Global South%unreliability%';

-- Verify what was updated
SELECT domain_slug, column_type, LEFT(content, 60) AS content_preview, source_url
FROM domain_panel_items
WHERE column_type IN ('caution', 'open') AND source_url IS NOT NULL
ORDER BY domain_slug, column_type, sort_order;
