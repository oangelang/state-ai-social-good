-- Create feedback table
-- Run in Supabase SQL Editor: https://supabase.com/dashboard/project/xvdkurbfxsukyxnykssy/sql

CREATE TABLE IF NOT EXISTS feedback (
  id         uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  name       text,
  email      text,
  message    text        NOT NULL,
  page       text,
  created_at timestamptz DEFAULT now()
);

-- Allow anyone (anon) to INSERT feedback
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can submit feedback"
  ON feedback FOR INSERT
  WITH CHECK (true);

-- Only authenticated users (you) can read it
CREATE POLICY "Authenticated users can read feedback"
  ON feedback FOR SELECT
  USING (auth.role() = 'authenticated');
