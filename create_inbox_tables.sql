-- Inbox Accounts Table
CREATE TABLE IF NOT EXISTS "public"."inbox_accounts" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "team_id" uuid NOT NULL,
  "email" text NOT NULL,
  "provider" text NOT NULL,
  "access_token" text,
  "refresh_token" text,
  "token_expires_at" timestamp with time zone,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
  "active" boolean DEFAULT true NOT NULL,
  "last_synced_at" timestamp with time zone
);

CREATE INDEX IF NOT EXISTS "inbox_accounts_team_id_idx" 
  ON "public"."inbox_accounts" USING btree ("team_id");
CREATE INDEX IF NOT EXISTS "inbox_accounts_email_idx" 
  ON "public"."inbox_accounts" USING btree ("email");

-- Inbox Table
CREATE TABLE IF NOT EXISTS "public"."inbox" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "team_id" uuid NOT NULL,
  "inbox_account_id" uuid,
  "transaction_id" uuid,
  "file_name" text,
  "file_path" text,
  "display_name" text,
  "amount" numeric,
  "currency" text,
  "content_type" text,
  "date" date,
  "status" text DEFAULT 'pending' NOT NULL,
  "website" text,
  "description" text,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS "inbox_team_id_idx" 
  ON "public"."inbox" USING btree ("team_id");
CREATE INDEX IF NOT EXISTS "inbox_status_idx" 
  ON "public"."inbox" USING btree ("status");
CREATE INDEX IF NOT EXISTS "inbox_transaction_id_idx" 
  ON "public"."inbox" USING btree ("transaction_id");
CREATE INDEX IF NOT EXISTS "inbox_inbox_account_id_idx" 
  ON "public"."inbox" USING btree ("inbox_account_id");
CREATE INDEX IF NOT EXISTS "inbox_created_at_idx" 
  ON "public"."inbox" USING btree ("created_at");

-- Add foreign key constraints
ALTER TABLE "public"."inbox_accounts" 
  DROP CONSTRAINT IF EXISTS "inbox_accounts_team_id_fkey";
ALTER TABLE "public"."inbox_accounts" 
  ADD CONSTRAINT "inbox_accounts_team_id_fkey" 
  FOREIGN KEY ("team_id") 
  REFERENCES "public"."teams"("id") 
  ON DELETE CASCADE;

ALTER TABLE "public"."inbox" 
  DROP CONSTRAINT IF EXISTS "inbox_team_id_fkey";
ALTER TABLE "public"."inbox" 
  ADD CONSTRAINT "inbox_team_id_fkey" 
  FOREIGN KEY ("team_id") 
  REFERENCES "public"."teams"("id") 
  ON DELETE CASCADE;

ALTER TABLE "public"."inbox" 
  DROP CONSTRAINT IF EXISTS "inbox_transaction_id_fkey";
ALTER TABLE "public"."inbox" 
  ADD CONSTRAINT "inbox_transaction_id_fkey" 
  FOREIGN KEY ("transaction_id") 
  REFERENCES "public"."transactions"("id") 
  ON DELETE SET NULL;

ALTER TABLE "public"."inbox" 
  DROP CONSTRAINT IF EXISTS "inbox_inbox_account_id_fkey";
ALTER TABLE "public"."inbox" 
  ADD CONSTRAINT "inbox_inbox_account_id_fkey" 
  FOREIGN KEY ("inbox_account_id") 
  REFERENCES "public"."inbox_accounts"("id") 
  ON DELETE SET NULL;
