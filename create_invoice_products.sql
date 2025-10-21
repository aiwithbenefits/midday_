-- Create invoice_products table
CREATE TABLE IF NOT EXISTS "public"."invoice_products" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
  "team_id" uuid NOT NULL,
  "created_by" uuid,
  "name" text NOT NULL,
  "description" text,
  "price" numeric NOT NULL,
  "currency" text NOT NULL,
  "unit" text,
  "is_active" boolean DEFAULT true NOT NULL,
  "usage_count" integer DEFAULT 0 NOT NULL,
  "last_used_at" timestamp with time zone,
  "fts" tsvector GENERATED ALWAYS AS (
    to_tsvector('english'::regconfig, 
      COALESCE(name, '') || ' ' || 
      COALESCE(description, '')
    )
  ) STORED
);

CREATE INDEX IF NOT EXISTS "invoice_products_team_id_idx" 
  ON "public"."invoice_products" USING btree ("team_id");
CREATE INDEX IF NOT EXISTS "invoice_products_last_used_at_idx" 
  ON "public"."invoice_products" USING btree ("last_used_at");
CREATE INDEX IF NOT EXISTS "invoice_products_fts_idx" 
  ON "public"."invoice_products" USING gin ("fts");

ALTER TABLE "public"."invoice_products" 
  DROP CONSTRAINT IF EXISTS "invoice_products_team_id_fkey";
ALTER TABLE "public"."invoice_products" 
  ADD CONSTRAINT "invoice_products_team_id_fkey" 
  FOREIGN KEY ("team_id") 
  REFERENCES "public"."teams"("id") 
  ON DELETE CASCADE;
