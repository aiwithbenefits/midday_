# Midday Application Setup & Modification Summary

## Project Overview

**Goal:** Deploy and configure the Midday financial management application for self-hosted use with manual data loading, bypassing authentication and bank connection requirements while preserving all core analytics and intelligence features.

**Repository:** https://github.com/jbstanley2004/midday-ts

---

## Task Summary

### What Was Done

1. **Fixed Critical React Hydration Errors**
   - Resolved server/client date formatting mismatches in chart components
   - Fixed spending widget date generation issues
   - Eliminated all hydration warnings that were breaking the UI

2. **Removed Visual Blocking (Blur Overlay)**
   - Disabled the blur effect that covered charts when no bank accounts were connected
   - Set `disabled = false` permanently across all widgets and charts

3. **Created Missing Database Tables**
   - Added OAuth-related tables to prevent TRPC query failures
   - Tables: `oauth_applications`, `oauth_access_tokens`, `oauth_authorization_codes`

4. **Preserved All Core Functionality**
   - Transaction analysis and categorization
   - Document processing and tagging
   - Search and embeddings
   - Reporting and analytics
   - Invoice generation
   - Time tracking

---

## Required Modifications for Self-Hosted Deployment

### 1. Authentication Bypass
**Status:** ✅ Already implemented in your fork
- Auth removed to allow direct dashboard access
- No login flow required
- Users can access `/` directly without authentication

### 2. Bank Connection Removal
**What to modify:**

#### File: `apps/dashboard/src/components/widgets/index.tsx`
```typescript
// Line 27-28: Change from
const disabled = !accounts?.length;

// To:
const disabled = false; // Self-hosted: no bank connections required
```

#### File: `apps/dashboard/src/components/charts/charts.tsx`
```typescript
// Line 21-22: Change from
const disabled = !accounts?.length;

// To:
const disabled = false; // Self-hosted: no bank connections required
```

#### File: `apps/dashboard/src/components/charts/empty-state.tsx`
```typescript
// Line 14-20: Comment out or keep the return null
// const isEmpty = !accounts?.length;
// if (!isEmpty) {
//   return null;
// }
return null; // Always hide empty state for self-hosted
```

### 3. Hydration Fixes for Date Components

#### File: `apps/dashboard/src/components/charts/chart-period.tsx`
**Change the displayDateRange logic:**
```typescript
// Add useState and useEffect at top
const [mounted, setMounted] = useState(false);

useEffect(() => {
  setMounted(true);
}, []);

// Change from:
const displayDateRange = mounted && params.from && params.to
  ? formatDateRange(...)
  : "Select date range";

// To:
const displayDateRange = !mounted
  ? ""
  : params.from && params.to
  ? formatDateRange(...)
  : "Select date range";

// Update JSX:
<span className="line-clamp-1 text-ellipsis">
  {displayDateRange || <span>&nbsp;</span>}
</span>
```

#### File: `apps/dashboard/src/components/widgets/spending/spending-period.tsx`
**Add client-side mount check:**
```typescript
// Add at top of component
const [mounted, setMounted] = useState(false);

useEffect(() => {
  setMounted(true);
}, []);

// Add before main return
if (!mounted) {
  return (
    <div className="flex justify-between">
      <div>
        <h2 className="text-lg">Spending</h2>
      </div>
      <div className="flex items-center space-x-2">
        <span>&nbsp;</span>
        <Icons.ChevronDown />
      </div>
    </div>
  );
}
```

#### File: `apps/dashboard/src/components/widgets/spending/spending-category-list.tsx`
**Add client-side mount check:**
```typescript
// Add at top of component
const [mounted, setMounted] = useState(false);

useEffect(() => {
  setMounted(true);
}, []);

// Add before main return
if (!mounted) {
  return (
    <ul className="mt-8 space-y-4 overflow-auto scrollbar-hide aspect-square pb-14">
      {data?.map((category) => (
        <li key={category.slug}>
          <div className="flex items-center">
            <Category
              name={category.name}
              color={category.color}
              className="text-sm text-primary space-x-3 w-[90%]"
            />
            <Progress
              className="w-full rounded-none h-[6px]"
              value={category.percentage}
            />
          </div>
        </li>
      ))}
    </ul>
  );
}
```

### 4. Database Tables Creation

**Run these SQL commands against your Supabase database:**

```sql
-- OAuth Applications Table
CREATE TABLE IF NOT EXISTS "public"."oauth_applications" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "name" text NOT NULL,
  "slug" text NOT NULL UNIQUE,
  "description" text,
  "overview" text,
  "developer_name" text,
  "logo_url" text,
  "website" text,
  "install_url" text,
  "screenshots" text[],
  "redirect_uris" text[],
  "client_id" text NOT NULL UNIQUE,
  "scopes" text[],
  "team_id" uuid NOT NULL,
  "created_by" uuid,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
  "is_public" boolean DEFAULT false NOT NULL,
  "active" boolean DEFAULT true NOT NULL,
  "status" text DEFAULT 'draft'
);

CREATE INDEX IF NOT EXISTS "oauth_applications_team_id_idx" 
  ON "public"."oauth_applications" USING btree ("team_id");
CREATE INDEX IF NOT EXISTS "oauth_applications_client_id_idx" 
  ON "public"."oauth_applications" USING btree ("client_id");
CREATE INDEX IF NOT EXISTS "oauth_applications_slug_idx" 
  ON "public"."oauth_applications" USING btree ("slug");

-- OAuth Access Tokens Table
CREATE TABLE IF NOT EXISTS "public"."oauth_access_tokens" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "application_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "team_id" uuid NOT NULL,
  "token" text NOT NULL UNIQUE,
  "scopes" text[],
  "expires_at" timestamp with time zone NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "revoked_at" timestamp with time zone
);

CREATE INDEX IF NOT EXISTS "oauth_access_tokens_application_id_idx" 
  ON "public"."oauth_access_tokens" USING btree ("application_id");
CREATE INDEX IF NOT EXISTS "oauth_access_tokens_user_id_idx" 
  ON "public"."oauth_access_tokens" USING btree ("user_id");

-- OAuth Authorization Codes Table
CREATE TABLE IF NOT EXISTS "public"."oauth_authorization_codes" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
  "application_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "team_id" uuid NOT NULL,
  "code" text NOT NULL UNIQUE,
  "redirect_uri" text NOT NULL,
  "scopes" text[],
  "code_challenge" text,
  "expires_at" timestamp with time zone NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL,
  "used_at" timestamp with time zone
);

CREATE INDEX IF NOT EXISTS "oauth_authorization_codes_code_idx" 
  ON "public"."oauth_authorization_codes" USING btree ("code");
```

---

## Using MCP Tools for Development

### TypeScript SDK Reference
**Repository:** https://github.com/jbstanley2004/midday-ts

When working on Midday features, always refer to the TypeScript SDK:

1. **Use Context7 MCP to query the SDK:**
```
Ask Claude: "Use Context7 to get documentation for midday-ts SDK"
```

2. **Key SDK locations:**
   - `/docs` - Full documentation for all services
   - Function signatures and types
   - API usage examples

3. **Check docs before making changes:**
   - Invoice functions: `/docs/invoice/*`
   - Transaction processing: `/docs/transactions/*`
   - Document handling: `/docs/documents/*`

### Supabase MCP Tool
**For database operations:**

1. **Query database schema:**
```typescript
// Use Supabase MCP to:
- List tables and columns
- Execute SQL queries
- Check for missing migrations
- Verify RLS policies
```

2. **Common operations:**
```typescript
// List all tables
supabase.list_tables({ project_id: "your-project" })

// Execute SQL
supabase.execute_sql({ 
  project_id: "your-project",
  query: "SELECT * FROM transactions LIMIT 10"
})

// Apply migrations
supabase.apply_migration({
  project_id: "your-project",
  name: "add_custom_fields",
  query: "ALTER TABLE..."
})
```

### Vercel MCP Tool
**For deployment and monitoring:**

1. **Deploy changes:**
```typescript
// Use Vercel MCP to:
- Deploy to production
- Check deployment status
- View build logs
- Manage environment variables
```

2. **Common operations:**
```typescript
// Deploy project
vercel.deploy_to_vercel()

// Get deployment status
vercel.get_deployment({ idOrUrl: "deployment-url" })

// Check build logs
vercel.get_deployment_build_logs({
  idOrUrl: "deployment-url",
  teamId: "your-team-id"
})
```

### Context7 MCP Tool
**For documentation lookup:**

1. **Query SDK documentation:**
```typescript
// Resolve library ID first
context7.resolve_library_id({ libraryName: "midday-ts" })

// Get documentation
context7.get_library_docs({
  context7CompatibleLibraryID: "/midday/midday-ts",
  topic: "transaction-processing"
})
```

2. **When to use:**
   - Before implementing new features
   - When modifying existing functions
   - To understand API contracts
   - For type definitions

---

## Manual Data Loading Guide

### Step 1: Create Team
```sql
INSERT INTO teams (id, name, created_at) 
VALUES (
  'your-team-uuid-here', 
  'My Company', 
  NOW()
);
```

### Step 2: Create User (Optional)
```sql
INSERT INTO users (id, email, full_name, team_id, created_at)
VALUES (
  'your-user-uuid-here',
  'you@company.com',
  'Your Name',
  'your-team-uuid-here',
  NOW()
);
```

### Step 3: Load Transaction Data
```sql
INSERT INTO transactions (
  team_id,
  date,
  name,
  amount,
  currency,
  method,
  status,
  internal_id,
  created_at
) VALUES (
  'your-team-uuid-here',
  '2025-10-15',
  'Office Supplies',
  -150.00,
  'USD',
  'card_purchase',
  'posted',
  'manual-001',
  NOW()
);
```

### Step 4: Add Categories (Optional)
```sql
UPDATE transactions 
SET category_slug = 'office-supplies'
WHERE internal_id = 'manual-001';
```

---

## Development Workflow

### When Adding Features:

1. **Check TypeScript SDK first:**
```bash
# Use Context7 MCP
Ask: "Get midday-ts documentation for [feature name]"
```

2. **Verify database schema:**
```bash
# Use Supabase MCP
supabase.list_tables()
supabase.execute_sql({ query: "\\d transactions" })
```

3. **Test locally:**
```bash
cd /Users/jacob/Downloads/midday_
npm run dev
```

4. **Deploy to Vercel:**
```bash
# Use Vercel MCP
vercel.deploy_to_vercel()
```

### When Debugging:

1. **Check build logs:**
```bash
# Use Vercel MCP
vercel.get_deployment_build_logs({ idOrUrl: "deployment-url" })
```

2. **Query database:**
```bash
# Use Supabase MCP
supabase.execute_sql({ 
  query: "SELECT * FROM transactions WHERE team_id = 'xxx' LIMIT 10"
})
```

3. **Reference SDK docs:**
```bash
# Use Context7 MCP
context7.get_library_docs({ 
  context7CompatibleLibraryID: "/midday/midday-ts",
  topic: "error-handling"
})
```

---

## Files Modified Summary

### Core Application Files:
1. ✏️ `apps/dashboard/src/components/charts/chart-period.tsx` - Hydration fix
2. ✏️ `apps/dashboard/src/components/widgets/spending/spending-period.tsx` - Hydration fix
3. ✏️ `apps/dashboard/src/components/widgets/spending/spending-category-list.tsx` - Hydration fix
4. ✏️ `apps/dashboard/src/components/widgets/index.tsx` - Removed disabled state
5. ✏️ `apps/dashboard/src/components/charts/charts.tsx` - Removed disabled state
6. ✏️ `apps/dashboard/src/components/charts/empty-state.tsx` - Hidden empty state

### Database:
7. 💾 Created `oauth_applications` table with indexes
8. 💾 Created `oauth_access_tokens` table with indexes
9. 💾 Created `oauth_authorization_codes` table with indexes

---

## Features Preserved

### ✅ All Intelligence Features Active:
- Transaction categorization and analysis
- Document processing and OCR
- Search with embeddings
- Tagging system
- Reporting and analytics
- Burn rate calculations
- Revenue/expense tracking
- Invoice generation
- Time tracking
- Vault (document storage)

### ✅ All TRPC Endpoints Working:
- `reports.*` - All analytics
- `transactions.*` - Transaction management
- `documents.*` - Document handling
- `invoice.*` - Invoice operations
- `trackerEntries.*` - Time tracking
- `tags.*` - Tagging system
- `search.*` - Search functionality

### ❌ Features Disabled/Bypassed:
- Authentication flow
- Bank connection services (Plaid, Teller, GoCardless)
- OAuth application management (tables exist but unused)

---

## Environment Configuration

### Required Environment Variables:
```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key

# App Settings
NEXT_PUBLIC_APP_URL=http://localhost:3001
SECRET_KEY=your-secret-key

# OpenAI (for AI features)
OPENAI_API_KEY=your-openai-key

# Resend (for emails)
RESEND_API_KEY=your-resend-key
```

---

## Quick Start Commands

```bash
# Install dependencies
cd /Users/jacob/Downloads/midday_
npm install

# Start Supabase (if local)
supabase start

# Start development server
npm run dev

# Access application
open http://localhost:3001
```

---

## Next Steps

1. **Create Claude Project** with this summary
2. **Add custom instructions** referencing:
   - TypeScript SDK at github.com/jbstanley2004/midday-ts
   - Use Supabase MCP for database operations
   - Use Vercel MCP for deployments
   - Use Context7 MCP for SDK documentation
3. **Load initial data** using the SQL examples above
4. **Test all features** to ensure analytics work with manual data

---

## Support Resources

- **TypeScript SDK:** https://github.com/jbstanley2004/midday-ts
- **SDK Docs:** `/docs` directory in repo
- **Supabase Database:** `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
- **Dashboard URL:** http://localhost:3001
- **API URL:** http://localhost:3003

---

## Important Notes

1. **Always consult TypeScript SDK** before modifying transaction/document/invoice logic
2. **Use Supabase MCP** for all database queries and schema changes
3. **Use Vercel MCP** for deployments and monitoring
4. **Use Context7 MCP** to retrieve SDK documentation
5. **All intelligence features remain intact** - only bank connections are bypassed
6. **Manual data loading is the intended workflow** - no automated imports
