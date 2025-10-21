-- Create total_duration function
-- This function calculates the total duration of all tracker entries for a given project
CREATE OR REPLACE FUNCTION total_duration(project tracker_projects)
RETURNS bigint
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(SUM(duration), 0)::bigint
  FROM tracker_entries
  WHERE project_id = project.id;
$$;

-- Create get_project_total_amount function
-- This function calculates the total amount (duration * rate) for a project
CREATE OR REPLACE FUNCTION get_project_total_amount(project tracker_projects)
RETURNS numeric
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    SUM(
      (duration / 3600.0) * COALESCE(rate, project.rate, 0)
    ), 
    0
  )::numeric
  FROM tracker_entries
  WHERE project_id = project.id;
$$;

-- Create global_search function
-- Create global_search function
-- This function performs full-text search across multiple tables
CREATE OR REPLACE FUNCTION global_search(
  search_term text,
  team_id_param uuid,
  language_param text DEFAULT 'english',
  max_results int DEFAULT 30,
  items_per_table_limit int DEFAULT 5,
  relevance_threshold numeric DEFAULT 0.01
)
RETURNS TABLE (
  id uuid,
  type text,
  title text,
  relevance float,
  created_at timestamptz,
  data jsonb
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  (
    -- Search transactions
    SELECT 
      t.id,
      'transaction'::text as type,
      t.name as title,
      ts_rank(t.fts, plainto_tsquery(language_param, COALESCE(search_term, '')))::float as relevance,
      t.date::timestamptz as created_at,
      jsonb_build_object(
        'id', t.id,
        'name', t.name,
        'amount', t.amount,
        'currency', t.currency,
        'date', t.date,
        'category', t.category_slug
      ) as data
    FROM transactions t
    WHERE t.team_id = team_id_param
      AND (
        search_term IS NULL 
        OR search_term = ''
        OR t.fts @@ plainto_tsquery(language_param, search_term)
      )
    ORDER BY relevance DESC
    LIMIT items_per_table_limit
  )
  UNION ALL
  (
    -- Search invoices
    SELECT 
      i.id,
      'invoice'::text as type,
      COALESCE(i.invoice_number, i.customer_name, 'Invoice')::text as title,
      ts_rank(i.fts, plainto_tsquery(language_param, COALESCE(search_term, '')))::float as relevance,
      i.created_at,
      jsonb_build_object(
        'id', i.id,
        'invoice_number', i.invoice_number,
        'customer_name', i.customer_name,
        'amount', i.amount,
        'currency', i.currency,
        'status', i.status,
        'due_date', i.due_date
      ) as data
    FROM invoices i
    WHERE i.team_id = team_id_param
      AND (
        search_term IS NULL 
        OR search_term = ''
        OR i.fts @@ plainto_tsquery(language_param, search_term)
      )
    ORDER BY relevance DESC
    LIMIT items_per_table_limit
  )
  UNION ALL
  (
    -- Search customers
    SELECT 
      c.id,
      'customer'::text as type,
      c.name as title,
      CASE 
        WHEN search_term IS NULL OR search_term = '' THEN 0.0
        ELSE similarity(c.name, search_term)::float
      END as relevance,
      c.created_at,
      jsonb_build_object(
        'id', c.id,
        'name', c.name,
        'email', c.email,
        'website', c.website
      ) as data
    FROM customers c
    WHERE c.team_id = team_id_param
      AND (
        search_term IS NULL 
        OR search_term = ''
        OR c.name ILIKE '%' || search_term || '%'
        OR c.email ILIKE '%' || search_term || '%'
      )
    ORDER BY relevance DESC
    LIMIT items_per_table_limit
  )
  UNION ALL
  (
    -- Search tracker projects
    SELECT 
      tp.id,
      'tracker_project'::text as type,
      tp.name as title,
      CASE 
        WHEN search_term IS NULL OR search_term = '' THEN 0.0
        ELSE similarity(tp.name, search_term)::float
      END as relevance,
      tp.created_at,
      jsonb_build_object(
        'id', tp.id,
        'name', tp.name,
        'description', tp.description,
        'status', tp.status
      ) as data
    FROM tracker_projects tp
    WHERE tp.team_id = team_id_param
      AND (
        search_term IS NULL 
        OR search_term = ''
        OR tp.name ILIKE '%' || search_term || '%'
        OR tp.description ILIKE '%' || search_term || '%'
      )
    ORDER BY relevance DESC
    LIMIT items_per_table_limit
  )
  ORDER BY relevance DESC
  LIMIT max_results;
END;
$$;

-- Enable pg_trgm extension for similarity searches if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_trgm;
