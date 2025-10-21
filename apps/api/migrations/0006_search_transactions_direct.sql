-- Direct text-based transaction search used by DB queries
CREATE OR REPLACE FUNCTION public.search_transactions_direct(
  p_team_id uuid,
  p_query text,
  p_max_results integer DEFAULT 5
)
RETURNS TABLE (
  transaction_id uuid,
  name text,
  transaction_amount numeric,
  transaction_currency text,
  transaction_date date,
  name_score numeric,
  amount_score numeric,
  currency_score numeric,
  date_score numeric,
  confidence_score numeric
)
LANGUAGE sql
STABLE
AS $$
  WITH base AS (
    SELECT
      t.id,
      t.name,
      t.amount,
      t.currency,
      t.date,
      -- build a tsvector from name+description if available
      to_tsvector('english', COALESCE(t.name,'') || ' ' || COALESCE(t.description,'')) AS vec
    FROM public.transactions t
    WHERE t.team_id = p_team_id
      AND (t.status IS NULL OR t.status <> 'excluded')
  ), ranked AS (
    SELECT
      b.id AS transaction_id,
      b.name,
      b.amount AS transaction_amount,
      b.currency AS transaction_currency,
      b.date AS transaction_date,
      ts_rank(b.vec, plainto_tsquery('english', p_query)) AS name_score
    FROM base b
    WHERE b.vec @@ plainto_tsquery('english', p_query)
    ORDER BY name_score DESC
    LIMIT COALESCE(p_max_results, 5)
  )
  SELECT
    r.transaction_id,
    r.name,
    r.transaction_amount,
    r.transaction_currency,
    r.transaction_date,
    COALESCE(r.name_score, 0)::numeric AS name_score,
    0.0::numeric AS amount_score,
    0.5::numeric AS currency_score,
    0.5::numeric AS date_score,
    LEAST(1.0, COALESCE(r.name_score, 0))::numeric AS confidence_score
  FROM ranked r
  ORDER BY r.name_score DESC, r.transaction_date DESC;
$$;
