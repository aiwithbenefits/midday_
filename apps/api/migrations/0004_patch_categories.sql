-- Patch: add missing columns used by queries
ALTER TABLE public.transaction_categories
  ADD COLUMN IF NOT EXISTS excluded boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS tax_rate numeric,
  ADD COLUMN IF NOT EXISTS tax_type text;

-- Ensure exchange rate self mapping exists
INSERT INTO public.exchange_rates (base, target, rate, updated_at)
VALUES ('USD','USD',1.0, now())
ON CONFLICT (base, target) DO UPDATE SET rate = EXCLUDED.rate, updated_at = now();
