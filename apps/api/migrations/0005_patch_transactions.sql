-- Patch transactions table to match application queries
ALTER TABLE public.transactions
  ADD COLUMN IF NOT EXISTS internal boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS notified boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS recurring boolean,
  ADD COLUMN IF NOT EXISTS counterparty_name text,
  ADD COLUMN IF NOT EXISTS frequency transaction_frequency,
  ADD COLUMN IF NOT EXISTS merchant_name text,
  ADD COLUMN IF NOT EXISTS enrichment_completed boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS tax_rate numeric,
  ADD COLUMN IF NOT EXISTS tax_type text;
