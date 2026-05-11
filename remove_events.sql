-- Remove two events from the site
-- Run in Supabase SQL Editor: https://supabase.com/dashboard/project/xvdkurbfxsukyxnykssy/sql

-- Preview first:
SELECT id, name, event_date FROM events
WHERE name ILIKE '%IJCAI%' OR name ILIKE '%AI Summit New York%';

-- Delete:
DELETE FROM events
WHERE name ILIKE '%IJCAI%' OR name ILIKE '%AI Summit New York%';
