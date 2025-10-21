-- Migration to create missing critical tables
-- These tables failed in the initial migration due to dependency ordering

-- Create teams table (critical - referenced by almost all other tables)
CREATE TABLE IF NOT EXISTS "teams" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"name" text,
	"logo_url" text,
	"inbox_id" text DEFAULT generate_inbox(10),
	"email" text,
	"inbox_email" text,
	"inbox_forwarding" boolean DEFAULT true,
	"base_currency" text,
	"country_code" text,
	"document_classification" boolean DEFAULT false,
	"flags" text[],
	"canceled_at" timestamp with time zone,
	"plan" "plans" DEFAULT 'pro' NOT NULL,  -- Changed from 'trial' to 'pro' for self-hosted
	"export_settings" jsonb,
	CONSTRAINT "teams_inbox_id_key" UNIQUE("inbox_id")
);

ALTER TABLE "teams" ENABLE ROW LEVEL SECURITY;

-- Create user_invites table (depends on teams)
CREATE TABLE IF NOT EXISTS "user_invites" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"team_id" uuid,
	"email" text,
	"role" "teamRoles",
	"code" text DEFAULT nanoid(24),
	"invited_by" uuid,
	CONSTRAINT "unique_team_invite" UNIQUE("team_id","email"),
	CONSTRAINT "user_invites_code_key" UNIQUE("code")
);

ALTER TABLE "user_invites" ENABLE ROW LEVEL SECURITY;

-- Create inbox table (depends on teams)
CREATE TABLE IF NOT EXISTS "inbox" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"team_id" uuid,
	"file_path" text[],
	"file_name" text,
	"transaction_id" uuid,
	"amount" numeric,
	"currency" text,
	"content_type" text,
	"size" bigint,
	"attachment_id" uuid,
	"date" date,
	"forwarded_to" text,
	"reference_id" text,
	"meta" json,
	"status" "inbox_status" DEFAULT 'new',
	"website" text,
	"display_name" text,
	"fts" "tsvector" GENERATED ALWAYS AS (generate_inbox_fts(display_name, extract_product_names((meta -> 'products'::text)))) STORED,
	"type" "inbox_type",
	"description" text,
	"base_amount" numeric,
	"base_currency" text,
	"tax_amount" numeric,
	"tax_rate" numeric,
	"tax_type" text,
	CONSTRAINT "inbox_reference_id_key" UNIQUE("reference_id")
);

ALTER TABLE "inbox" ENABLE ROW LEVEL SECURITY;

-- Create transaction_categories table (depends on teams)
CREATE TABLE IF NOT EXISTS "transaction_categories" (
	"id" uuid DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"team_id" uuid DEFAULT gen_random_uuid() NOT NULL,
	"color" text,
	"created_at" timestamp with time zone DEFAULT now(),
	"system" boolean DEFAULT false,
	"slug" text NOT NULL,
	"vat" numeric,
	"description" text,
	"embedding" vector(384),
	CONSTRAINT "transaction_categories_pkey" PRIMARY KEY("team_id","slug"),
	CONSTRAINT "unique_team_slug" UNIQUE("team_id","slug")
);

ALTER TABLE "transaction_categories" ENABLE ROW LEVEL SECURITY;

-- Add foreign key constraints for new tables
ALTER TABLE "user_invites" 
  ADD CONSTRAINT "public_user_invites_team_id_fkey" 
  FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;

ALTER TABLE "user_invites" 
  ADD CONSTRAINT "user_invites_invited_by_fkey" 
  FOREIGN KEY ("invited_by") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;

ALTER TABLE "inbox" 
  ADD CONSTRAINT "inbox_attachment_id_fkey" 
  FOREIGN KEY ("attachment_id") REFERENCES "public"."transaction_attachments"("id") ON DELETE set null ON UPDATE no action;

ALTER TABLE "inbox" 
  ADD CONSTRAINT "public_inbox_team_id_fkey" 
  FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;

ALTER TABLE "inbox" 
  ADD CONSTRAINT "public_inbox_transaction_id_fkey" 
  FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions"("id") ON DELETE set null ON UPDATE no action;

ALTER TABLE "transaction_categories" 
  ADD CONSTRAINT "transaction_categories_team_id_fkey" 
  FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE cascade ON UPDATE no action;

-- Add indexes for new tables
CREATE INDEX IF NOT EXISTS "user_invites_team_id_idx" ON "user_invites" USING btree ("team_id" uuid_ops);
CREATE INDEX IF NOT EXISTS "inbox_attachment_id_idx" ON "inbox" USING btree ("attachment_id" uuid_ops);
CREATE INDEX IF NOT EXISTS "inbox_created_at_idx" ON "inbox" USING btree ("created_at" timestamptz_ops);
CREATE INDEX IF NOT EXISTS "inbox_team_id_idx" ON "inbox" USING btree ("team_id" uuid_ops);
CREATE INDEX IF NOT EXISTS "inbox_transaction_id_idx" ON "inbox" USING btree ("transaction_id" uuid_ops);
CREATE INDEX IF NOT EXISTS "transaction_categories_team_id_idx" ON "transaction_categories" USING btree ("team_id" uuid_ops);

-- Create RLS policies for new tables
CREATE POLICY "Enable select for users based on email" ON "user_invites" 
  AS PERMISSIVE FOR SELECT TO public 
  USING ((auth.jwt() ->> 'email'::text) = email);

CREATE POLICY "User Invites can be created by a member of the team" ON "user_invites" 
  AS PERMISSIVE FOR INSERT TO public;

CREATE POLICY "User Invites can be deleted by a member of the team" ON "user_invites" 
  AS PERMISSIVE FOR DELETE TO public;

CREATE POLICY "User Invites can be deleted by invited email" ON "user_invites" 
  AS PERMISSIVE FOR DELETE TO public;

CREATE POLICY "User Invites can be selected by a member of the team" ON "user_invites" 
  AS PERMISSIVE FOR SELECT TO public;

CREATE POLICY "User Invites can be updated by a member of the team" ON "user_invites" 
  AS PERMISSIVE FOR UPDATE TO public;

CREATE POLICY "Enable insert for authenticated users only" ON "teams" 
  AS PERMISSIVE FOR INSERT TO "authenticated" 
  WITH CHECK (true);

CREATE POLICY "Invited users can select team if they are invited." ON "teams" 
  AS PERMISSIVE FOR SELECT TO public;

CREATE POLICY "Teams can be deleted by a member of the team" ON "teams" 
  AS PERMISSIVE FOR DELETE TO public;

CREATE POLICY "Teams can be selected by a member of the team" ON "teams" 
  AS PERMISSIVE FOR SELECT TO public;

CREATE POLICY "Teams can be updated by a member of the team" ON "teams" 
  AS PERMISSIVE FOR UPDATE TO public;

CREATE POLICY "Inbox can be deleted by a member of the team" ON "inbox" 
  AS PERMISSIVE FOR DELETE TO public 
  USING ((team_id IN ( SELECT private.get_teams_for_authenticated_user() AS get_teams_for_authenticated_user)));

CREATE POLICY "Inbox can be selected by a member of the team" ON "inbox" 
  AS PERMISSIVE FOR SELECT TO public;

CREATE POLICY "Inbox can be updated by a member of the team" ON "inbox" 
  AS PERMISSIVE FOR UPDATE TO public;

CREATE POLICY "Users on team can manage categories" ON "transaction_categories" 
  AS PERMISSIVE FOR ALL TO public 
  USING ((team_id IN ( SELECT private.get_teams_for_authenticated_user() AS get_teams_for_authenticated_user)));

-- Comment for documentation
COMMENT ON TABLE teams IS 'Teams table with default plan set to pro for self-hosted deployment';
