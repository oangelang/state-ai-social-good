-- Add new ecosystem + organization entries from LinkedIn field research
-- Run in Supabase SQL Editor: https://supabase.com/dashboard/project/xvdkurbfxsukyxnykssy/sql

-- ── ECOSYSTEM ─────────────────────────────────────────────────────────────────

INSERT INTO ecosystem (name, ecosystem_category, description, url, status) VALUES

-- Funders
('Hewlett Foundation',      'funder',        'Long-term funder of AI policy and democratic safeguards. Referenced for sustained investment in responsible AI governance and civil society.', 'https://hewlett.org', 'published'),
('Google.org',              'funder',        '"AI for the Global Goals" — fellowship programs placing tech talent inside nonprofits. Active grants and deployments across climate, health, and education.', 'https://google.org', 'published'),
('Microsoft Philanthropies','funder',        'Focus on AI skills, certifications, and cloud infrastructure for K-12 education and nonprofit capacity building.', 'https://microsoft.com/en-us/philanthropies', 'published'),
('The Global Fund',         'funder',        'Uses AI to improve coordination and targeting in global health initiatives covering HIV, TB, and malaria across 100+ countries.', 'https://theglobalfund.org', 'published'),

-- Conveners & Field-builders
('Tech to the Rescue',      'convener',      'Platform matching tech companies with nonprofits to build custom AI solutions at no cost. One of the most active connectors in the field.', 'https://techtotherescue.org', 'published'),
('NetHope',                 'convener',      'Consortium connecting 60+ major INGOs on humanitarian logistics and advanced data systems in crisis zones. The coordination layer the sector often lacks.', 'https://nethope.org', 'published'),
('Code for America',        'field-builder', '"Justice by Design" — ethical use of AI in government services. Builds and deploys open-source civic tech at state and local scale with real users.', 'https://codeforamerica.org', 'published'),
('Tech Matters',            'field-builder', 'Builds shovel-ready open-source AI tools for the social sector — deployable, maintainable, and community-owned rather than grant-dependent.', 'https://techmatters.org', 'published'),
('Beeck Center for Social Impact + Innovation', 'field-builder', 'Georgetown-based center aggregating data for public good. Active on data sovereignty, shared infrastructure, and translating AI research into policy.', 'https://beeckcenter.georgetown.edu', 'published'),
('Board.dev',               'field-builder', 'Places technology leaders on nonprofit boards to close the tech literacy gap and guide AI strategy at the governance level.', 'https://board.dev', 'published'),
('Numantic Solutions',      'field-builder', 'Data consultancy helping nonprofits build custom AI products and strategic datasets. Active at AI for Good summits.', 'https://numantic.com', 'published'),
('Six Feet Up',             'field-builder', 'Technical leadership helping mission-driven organizations apply AI practically. Known for implementation work that survives beyond the pilot.', 'https://sixfeetup.com', 'published'),
('CIVIC — World Bank',      'convener',      'Civil Society and Social Innovation Alliance at the World Bank. Builds the rails connecting policy intent to citizen engagement and closes the feedback loop.', 'https://worldbank.org/en/topic/social-sustainability', 'published'),
('Giga — UNICEF & ITU',    'field-builder', 'Mapping every school in the world using AI and satellite imagery to guide internet connectivity investments. 90+ countries, open data.', 'https://giga.global', 'published'),

-- Venture & Growth
('Khosla Ventures',         'vc',            'Vinod Khosla is a leading voice on venture-scale investments in "Good Tech" — particularly health diagnostics and climate infrastructure.', 'https://khoslaventures.com', 'published'),
('FoundersX Ventures',      'vc',            'Active in the AI for Good venture space, focusing on ethical AI and technical infrastructure that serves public benefit.', 'https://foundersxvc.com', 'published'),
('Fusion Fund',             'vc',            'Focused on ethical AI and technical infrastructure serving the public good. Active in AI for Good investment conversations.', 'https://fusionfund.com', 'published');


-- ── ORGANIZATIONS (doing direct domain work) ──────────────────────────────────

INSERT INTO organizations (name, description, ai_use_case, domain_tags, evidence_tier, source_url, status) VALUES

('Conservation International',
 'One of the world''s largest conservation organizations, integrating AI across science and operations to protect critical ecosystems.',
 'AI supercharging conservation science — species monitoring, habitat mapping, illegal activity detection at scale across 70+ countries.',
 ARRAY['climate','ocean'], 'deployed', 'https://conservation.org', 'published'),

('Clay',
 'AI platform turning Earth observation data from a niche scientific language into a universal utility for conservation and climate work.',
 'Foundation model for Earth data — making satellite, sensor, and geospatial data queryable and actionable for non-specialists.',
 ARRAY['climate'], 'pilot', 'https://clay.earth', 'published'),

('Giga — UNICEF & ITU',
 'Joint UNICEF/ITU initiative mapping every school in the world to guide internet connectivity investments.',
 'AI + satellite imagery identifies unconnected schools in 90+ countries; open data used by governments and ISPs to prioritize infrastructure.',
 ARRAY['education','equity'], 'deployed', 'https://giga.global', 'published');
