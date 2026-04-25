-- Restore all open questions (deleted by the uncited cleanup — questions don't need citations)
-- Run in Supabase SQL Editor: https://supabase.com/dashboard/project/xvdkurbfxsukyxnykssy/sql

INSERT INTO domain_panel_items (domain_slug, column_type, sort_order, content, status) VALUES

-- CLIMATE
('climate', 'open', 1, 'Can AI for climate survive structurally without tech company funding?', 'published'),
('climate', 'open', 2, 'Who owns training data from the communities bearing the most climate risk?', 'published'),
('climate', 'open', 3, 'How do we evaluate tools that work in pilots but haven''t survived a grant cycle?', 'published'),

-- HEALTH
('health', 'open', 1, 'How do we build training datasets representing communities most affected by health inequity?', 'published'),
('health', 'open', 2, 'Who is liable when an AI health tool fails in a resource-constrained context with no fallback?', 'published'),
('health', 'open', 3, 'Can offline-capable diagnostic tools be built that function without connectivity?', 'published'),

-- OCEAN
('ocean', 'open', 1, 'Can AI close the ocean data gap before irreversible tipping points are crossed?', 'published'),
('ocean', 'open', 2, 'What role should fishing communities play in designing tools that monitor their waters?', 'published'),
('ocean', 'open', 3, 'How do we build open-source ocean data frameworks not owned by a single company or government?', 'published'),

-- FOOD
('food', 'open', 1, 'Can voice-first, multilingual agricultural AI be built for low-literacy users at a cost nonprofits can sustain?', 'published'),
('food', 'open', 2, 'Where are the open-source crop disease models trained on Global South data?', 'published'),
('food', 'open', 3, 'How do we ensure smallholder farmers are co-designers, not just end users?', 'published'),

-- EQUITY
('equity', 'open', 1, 'Can participatory design actually scale, or does it only work for small pilots with dedicated teams?', 'published'),
('equity', 'open', 2, 'Who builds independent auditing infrastructure for AI in high-stakes economic contexts?', 'published'),

-- EDUCATION
('education', 'open', 1, 'Why does EdTech AI keep working in pilots and failing at scale?', 'published'),
('education', 'open', 2, 'How do we build offline-first AI education tools for low-connectivity classrooms?', 'published'),

-- HUMANITARIAN
('humanitarian', 'open', 1, 'What are minimum ethical standards for AI in contexts where people cannot meaningfully consent or opt out?', 'published'),
('humanitarian', 'open', 2, 'Who holds humanitarian AI systems accountable when they fail the most vulnerable people?', 'published'),

-- ENERGY
('energy', 'open', 1, 'How do we account for AI''s own energy footprint when measuring its impact on clean energy?', 'published'),
('energy', 'open', 2, 'Who ensures AI-accelerated material discoveries reach manufacturing at a cost accessible to lower-income markets?', 'published');
