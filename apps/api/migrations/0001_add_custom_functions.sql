-- Custom database functions required by Midday application
-- This migration adds helper functions for RLS policies, inbox generation, and nanoid generation

-- Create private schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS private;

-- 1. Function to get teams for authenticated user (used in RLS policies)
CREATE OR REPLACE FUNCTION private.get_teams_for_authenticated_user()
RETURNS uuid[] AS $$
  SELECT ARRAY_AGG(team_id)
  FROM users_on_team
  WHERE user_id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 2. Function to generate random inbox IDs
CREATE OR REPLACE FUNCTION generate_inbox(length int DEFAULT 10)
RETURNS text AS $$
  SELECT string_agg(
    substr('abcdefghijklmnopqrstuvwxyz0123456789', ceil(random() * 36)::int, 1),
    ''
  )
  FROM generate_series(1, length);
$$ LANGUAGE sql VOLATILE;

-- 3. Function to generate full-text search vectors for inbox
CREATE OR REPLACE FUNCTION generate_inbox_fts(display_name text, product_names text)
RETURNS tsvector AS $$
  SELECT to_tsvector('english', COALESCE(display_name, '') || ' ' || COALESCE(product_names, ''));
$$ LANGUAGE sql IMMUTABLE;

-- 4. Function to extract product names from JSONB
CREATE OR REPLACE FUNCTION extract_product_names(products jsonb)
RETURNS text AS $$
  SELECT string_agg(value->>'name', ' ')
  FROM jsonb_array_elements(COALESCE(products, '[]'::jsonb));
$$ LANGUAGE sql IMMUTABLE;

-- 5. Function to generate nanoid-style IDs  
CREATE OR REPLACE FUNCTION nanoid(size int DEFAULT 24)
RETURNS text AS $$
  SELECT string_agg(
    substr('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', ceil(random() * 62)::int, 1),
    ''
  )
  FROM generate_series(1, size);
$$ LANGUAGE sql VOLATILE;

-- Comments for documentation
COMMENT ON FUNCTION private.get_teams_for_authenticated_user IS 'Returns array of team IDs that the authenticated user belongs to';
COMMENT ON FUNCTION generate_inbox IS 'Generates a random alphanumeric string for inbox IDs';
COMMENT ON FUNCTION generate_inbox_fts IS 'Generates tsvector for full-text search on inbox items';
COMMENT ON FUNCTION extract_product_names IS 'Extracts and concatenates product names from JSONB array';
COMMENT ON FUNCTION nanoid IS 'Generates a nanoid-style random string';
