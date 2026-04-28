-- Remove duplicate ecosystem entries, keeping the most recently created one per name
-- Run in Supabase SQL Editor: https://supabase.com/dashboard/project/xvdkurbfxsukyxnykssy/sql

-- Preview what will be deleted first:
SELECT id, name, ecosystem_category, created_at
FROM ecosystem
WHERE id NOT IN (
  SELECT DISTINCT ON (name) id
  FROM ecosystem
  ORDER BY name, created_at DESC
);

-- Then run the delete:
DELETE FROM ecosystem
WHERE id NOT IN (
  SELECT DISTINCT ON (name) id
  FROM ecosystem
  ORDER BY name, created_at DESC
);

-- Verify — should show one row per name:
SELECT name, ecosystem_category, COUNT(*) as count
FROM ecosystem
GROUP BY name, ecosystem_category
ORDER BY name;
