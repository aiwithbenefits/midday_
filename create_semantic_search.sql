-- Create global_semantic_search function
-- This is a more advanced search with filters
CREATE OR REPLACE FUNCTION global_semantic_search(
  team_id_param uuid,
  search_term_param text,
  start_date_param text,
  end_date_param text,
  types_param text[],
  amount_param numeric,
  amount_min_param numeric,
  amount_max_param numeric,
  status_param text,
  currency_param text,
  language_param text DEFAULT 'english',
  due_date_start_param text DEFAULT NULL,
  due_date_end_param text DEFAULT NULL,
  max_results int DEFAULT 20,
  items_per_table_limit int DEFAULT 5
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
DECLARE
  search_transactions boolean;
  search_invoices boolean;
  search_customers boolean;
  search_projects boolean;
BEGIN
  -- Determine which tables to search
  search_transactions := types_param IS NULL OR 'transaction' = ANY(types_param);
  search_invoices := types_param IS NULL OR 'invoice' = ANY(types_param);
  search_customers := types_param IS NULL OR 'customer' = ANY(types_param);
  search_projects := types_param IS NULL OR 'tracker_project' = ANY(types_param);

  RETURN QUERY
  (
    -- Search transactions
    SELECT * FROM (
      SELECT 
        t.id,
        'transaction'::text as type,
        t.name as title,
        ts_rank(t.fts, plainto_tsquery(language_param, COALESCE(search_term_param, '')))::float as relevance,
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
        AND search_transactions
        AND (search_term_param IS NULL OR search_term_param = '' OR t.fts @@ plainto_tsquery(language_param, search_term_param))
        AND (start_date_param IS NULL OR t.date >= start_date_param::date)
        AND (end_date_param IS NULL OR t.date <= end_date_param::date)
        AND (amount_param IS NULL OR t.amount = amount_param)
        AND (amount_min_param IS NULL OR t.amount >= amount_min_param)
        AND (amount_max_param IS NULL OR t.amount <= amount_max_param)
        AND (currency_param IS NULL OR t.currency = currency_param)
      ORDER BY relevance DESC
      LIMIT items_per_table_limit
    ) transactions_results
  )
  UNION ALL
  (
    -- Search invoices
    SELECT * FROM (
      SELECT 
        i.id,
        'invoice'::text as type,
        COALESCE(i.invoice_number, i.customer_name, 'Invoice')::text as title,
        ts_rank(i.fts, plainto_tsquery(language_param, COALESCE(search_term_param, '')))::float as relevance,
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
        AND search_invoices
        AND (search_term_param IS NULL OR search_term_param = '' OR i.fts @@ plainto_tsquery(language_param, search_term_param))
        AND (start_date_param IS NULL OR i.created_at >= start_date_param::timestamptz)
        AND (end_date_param IS NULL OR i.created_at <= end_date_param::timestamptz)
        AND (amount_param IS NULL OR i.amount = amount_param)
        AND (amount_min_param IS NULL OR i.amount >= amount_min_param)
        AND (amount_max_param IS NULL OR i.amount <= amount_max_param)
        AND (status_param IS NULL OR i.status::text = status_param)
        AND (currency_param IS NULL OR i.currency = currency_param)
        AND (due_date_start_param IS NULL OR i.due_date >= due_date_start_param::timestamptz)
        AND (due_date_end_param IS NULL OR i.due_date <= due_date_end_param::timestamptz)
      ORDER BY relevance DESC
      LIMIT items_per_table_limit
    ) invoices_results
  )
  UNION ALL
  (
    -- Search customers
    SELECT * FROM (
      SELECT 
        c.id,
        'customer'::text as type,
        c.name as title,
        CASE 
          WHEN search_term_param IS NULL OR search_term_param = '' THEN 0.0
          ELSE similarity(c.name, search_term_param)::float
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
        AND search_customers
        AND (search_term_param IS NULL OR search_term_param = '' OR c.name ILIKE '%' || search_term_param || '%' OR c.email ILIKE '%' || search_term_param || '%')
      ORDER BY relevance DESC
      LIMIT items_per_table_limit
    ) customers_results
  )
  UNION ALL
  (
    -- Search tracker projects
    SELECT * FROM (
      SELECT 
        tp.id,
        'tracker_project'::text as type,
        tp.name as title,
        CASE 
          WHEN search_term_param IS NULL OR search_term_param = '' THEN 0.0
          ELSE similarity(tp.name, search_term_param)::float
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
        AND search_projects
        AND (search_term_param IS NULL OR search_term_param = '' OR tp.name ILIKE '%' || search_term_param || '%' OR tp.description ILIKE '%' || search_term_param || '%')
      ORDER BY relevance DESC
      LIMIT items_per_table_limit
    ) projects_results
  )
  ORDER BY relevance DESC
  LIMIT max_results;
END;
$$;
