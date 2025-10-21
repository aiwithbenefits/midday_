-- Seed demo data for self-hosted local development
-- Creates a default team, user, bank account, transactions, and an inbox item

-- 1) Seed default team (hardcoded ID used by API auth bypass)
INSERT INTO public.teams (id, name, plan, base_currency, email)
VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Local Team', 'pro', 'USD', 'admin@local.dev')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- 2) Seed default user (hardcoded ID used by API auth bypass)
INSERT INTO public.users (id, email, full_name, team_id)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'admin@local.dev', 'Local Admin', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb')
ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;

-- 3) Link user to team as owner
INSERT INTO public.users_on_team (user_id, team_id, id, role)
VALUES (
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  gen_random_uuid(),
  'owner'
)
ON CONFLICT DO NOTHING;

-- 4) Ensure USD->USD exchange rate exists
INSERT INTO public.exchange_rates (base, target, rate, updated_at)
VALUES ('USD','USD',1.0, now())
ON CONFLICT (base, target) DO UPDATE SET rate = EXCLUDED.rate, updated_at = now();

-- 5) Seed a demo bank connection and account
WITH ins_conn AS (
  INSERT INTO public.bank_connections (id, institution_id, team_id, name, provider, status, created_at)
  VALUES (
    gen_random_uuid(), 'demo_institution', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Demo Bank', 'plaid', 'connected', now()
  )
  RETURNING id
), ins_acct AS (
  INSERT INTO public.bank_accounts (id, created_by, team_id, name, currency, bank_connection_id, account_id, enabled, manual, balance, base_currency, base_balance, created_at)
  SELECT gen_random_uuid(), 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'USD Checking', 'USD', id, 'demo_checking', true, true, 10000, 'USD', 10000, now()
  FROM ins_conn
  RETURNING id
)
-- 6) Seed a few demo transactions
INSERT INTO public.transactions (id, team_id, bank_account_id, name, method, status, amount, currency, date, internal_id, manual, notified)
SELECT gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', id, 'AWS', 'other', 'posted', -123.45, 'USD', (CURRENT_DATE - INTERVAL '2 days')::date, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb_' || substring(gen_random_uuid()::text from 1 for 8), true, true FROM ins_acct
UNION ALL
SELECT gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', id, 'Figma', 'other', 'posted', -25.00, 'USD', (CURRENT_DATE - INTERVAL '1 day')::date, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb_' || substring(gen_random_uuid()::text from 1 for 8), true, true FROM ins_acct
UNION ALL
SELECT gen_random_uuid(), 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', id, 'Stripe Payout', 'deposit', 'posted', 500.00, 'USD', (CURRENT_DATE - INTERVAL '3 days')::date, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb_' || substring(gen_random_uuid()::text from 1 for 8), true, true FROM ins_acct;

-- 7) Seed a demo inbox item roughly matching the AWS transaction
INSERT INTO public.inbox (
  id, team_id, display_name, file_name, file_path, content_type, amount, currency, date, status, created_at
) VALUES (
  gen_random_uuid(),
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  'Amazon Web Services Invoice',
  'aws-invoice.pdf',
  ARRAY['demo','inbox','aws-invoice.pdf'],
  'application/pdf',
  123.45,
  'USD',
  (CURRENT_DATE - INTERVAL '2 days')::date,
  'pending',
  now()
) ON CONFLICT DO NOTHING;
