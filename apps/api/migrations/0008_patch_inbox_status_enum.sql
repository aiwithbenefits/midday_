-- Ensure inbox_status enum includes all states used by the app
DO $$ BEGIN
  ALTER TYPE public.inbox_status ADD VALUE IF NOT EXISTS 'analyzing';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER TYPE public.inbox_status ADD VALUE IF NOT EXISTS 'suggested_match';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER TYPE public.inbox_status ADD VALUE IF NOT EXISTS 'no_match';
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
