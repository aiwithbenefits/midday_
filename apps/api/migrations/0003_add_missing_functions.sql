-- Create missing table (safe if already exists via Drizzle): transaction_match_suggestions
CREATE TABLE IF NOT EXISTS public.transaction_match_suggestions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    team_id uuid NOT NULL,
    inbox_id uuid NOT NULL,
    transaction_id uuid NOT NULL,
    confidence_score numeric(4, 3) NOT NULL,
    amount_score numeric(4, 3),
    currency_score numeric(4, 3),
    date_score numeric(4, 3),
    embedding_score numeric(4, 3),
    name_score numeric(4, 3),
    match_type text NOT NULL,
    match_details jsonb,
    status text DEFAULT 'pending' NOT NULL,
    user_action_at timestamptz,
    user_id uuid
);

-- Create indexes
CREATE INDEX IF NOT EXISTS transaction_match_suggestions_team_id_idx ON public.transaction_match_suggestions(team_id);
CREATE INDEX IF NOT EXISTS transaction_match_suggestions_transaction_id_idx ON public.transaction_match_suggestions(transaction_id);
CREATE INDEX IF NOT EXISTS transaction_match_suggestions_inbox_id_idx ON public.transaction_match_suggestions(inbox_id);

-- Function: get_next_invoice_number(team_id)
CREATE OR REPLACE FUNCTION public.get_next_invoice_number(p_team_id uuid)
RETURNS text
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  last_no text;
  prefix text;
  num_part text;
  next_num bigint;
  result text;
BEGIN
  SELECT i.invoice_number
  INTO last_no
  FROM public.invoices i
  WHERE i.team_id = p_team_id AND i.invoice_number IS NOT NULL
  ORDER BY i.created_at DESC, i.id DESC
  LIMIT 1;

  IF last_no IS NULL OR btrim(last_no) = '' THEN
    RETURN 'INV-0001';
  END IF;

  -- Extract numeric suffix, everything before it is prefix
  prefix := regexp_replace(last_no, '(\d+)$', '');
  num_part := regexp_replace(last_no, '^.*?(\d+)$', '\1');

  IF num_part ~ '^\d+$' THEN
    next_num := (num_part)::bigint + 1;
  ELSE
    next_num := 1;
  END IF;

  result := prefix || lpad(next_num::text, 4, '0');
  RETURN result;
END;
$$;

-- Function: get_team_bank_accounts_balances(team_id)
CREATE OR REPLACE FUNCTION public.get_team_bank_accounts_balances(p_team_id uuid)
RETURNS TABLE(balance numeric, name text, logo_url text)
LANGUAGE sql
STABLE
AS $$
WITH team AS (
  SELECT base_currency FROM public.teams WHERE id = p_team_id
), accts AS (
  SELECT
    ba.id,
    ba.team_id,
    ba.balance,
    ba.currency,
    ba.base_balance,
    ba.base_currency,
    bc.name,
    bc.logo_url,
    COALESCE(
      CASE
        WHEN ba.base_balance IS NOT NULL AND ba.base_currency IS NOT NULL AND ba.base_currency = (SELECT base_currency FROM team)
          THEN ba.base_balance
        WHEN ba.balance IS NOT NULL AND ba.currency IS NOT NULL AND (SELECT base_currency FROM team) IS NOT NULL
          THEN ba.balance * COALESCE((SELECT er.rate FROM public.exchange_rates er WHERE er.base = ba.currency AND er.target = (SELECT base_currency FROM team) LIMIT 1), 1)
        ELSE ba.balance
      END, 0
    ) AS balance_converted
  FROM public.bank_accounts ba
  LEFT JOIN public.bank_connections bc ON bc.id = ba.bank_connection_id
  WHERE ba.team_id = p_team_id
)
SELECT
  SUM(balance_converted) AS balance,
  name,
  logo_url
FROM accts
GROUP BY name, logo_url
ORDER BY COALESCE(SUM(balance_converted),0) DESC;
$$;

-- Function: get_bank_account_currencies(team_id)
CREATE OR REPLACE FUNCTION public.get_bank_account_currencies(p_team_id uuid)
RETURNS TABLE(currency text)
LANGUAGE sql
STABLE
AS $$
  SELECT DISTINCT ba.currency
  FROM public.bank_accounts ba
  WHERE ba.team_id = p_team_id AND ba.currency IS NOT NULL
  ORDER BY 1;
$$;

-- Function: get_payment_score(team_id)
-- Very simple heuristic: ratio of paid invoices and a status summary
CREATE OR REPLACE FUNCTION public.get_payment_score(p_team_id uuid)
RETURNS TABLE(score numeric, payment_status text)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_total integer := 0;
  v_paid integer := 0;
  v_overdue integer := 0;
  v_score numeric := 0;
  v_status text := 'pending';
BEGIN
  SELECT
    COUNT(*)::int,
    COUNT(*) FILTER (WHERE status = 'paid')::int,
    COUNT(*) FILTER (WHERE (status IS DISTINCT FROM 'paid' AND status IS DISTINCT FROM 'canceled') AND (due_date IS NOT NULL AND due_date < now()))::int
  INTO v_total, v_paid, v_overdue
  FROM public.invoices
  WHERE team_id = p_team_id;

  IF v_total > 0 THEN
    v_score := LEAST(1, GREATEST(0, v_paid::numeric / v_total::numeric));
  ELSE
    v_score := 0;
  END IF;

  IF v_overdue > 0 THEN
    v_status := 'overdue';
  ELSIF v_total > 0 AND v_paid = v_total THEN
    v_status := 'paid';
  ELSIF v_total = 0 THEN
    v_status := 'no_invoices';
  ELSE
    v_status := 'pending';
  END IF;

  RETURN QUERY SELECT v_score, v_status;
END;
$$;
