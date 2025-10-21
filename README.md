# Midday - Self-Hosted Financial Management Platform

![hero](github.png)

<p align="center">
    <h1 align="center"><b>Midday</b></h1>
    <p align="center">
        Run your business smarter with intelligent financial management
        <br />
        <br />
        <a href="https://go.midday.ai/anPiuRx">Discord</a>
        ·
        <a href="https://midday.ai">Website</a>
        ·
        <a href="https://github.com/midday-ai/midday/issues">Issues</a>
    </p>
</p>

<p align="center">
  <a href="https://go.midday.ai/K7GwMoQ">
    <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  </a>
</p>

---

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Environment Setup](#environment-setup)
- [Starting the Application](#starting-the-application)
- [API Endpoints](#api-endpoints)
- [Recent Modifications](#recent-modifications)
- [Fork Management](#fork-management)
- [Architecture](#architecture)
- [Manual Data Loading](#manual-data-loading)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## 🎯 About

Midday is an all-in-one financial management platform designed for freelancers, contractors, consultants, and solo entrepreneurs. This forked version has been customized for self-hosted deployment with enhanced features and fixes.

**This Fork Includes:**
- ✅ Fixed PDF viewer with proper path handling
- ✅ Enhanced inbox document processing
- ✅ Database migration patches (0001-0008)
- ✅ Improved error handling and logging
- ✅ Supabase configuration and setup
- ✅ Comprehensive documentation and guides
- ✅ Docker compose setup for Redis

**Repository:** https://github.com/aiwithbenefits/midday_

---

## ✨ Features

### Core Functionality

**📊 Time Tracking**
- Live time tracking for projects
- Boost productivity and collaboration
- Insightful project overviews and reports
- Customer and project assignment

**💰 Invoicing**
- Create professional web-based invoices
- Real-time collaboration
- Seamless project synchronization
- Customizable templates and branding

**📧 Magic Inbox**
- Automatically match invoices and receipts to transactions
- Smart document categorization
- PDF viewer with enhanced error handling
- Transaction linkage and tagging

**🗄️ Vault**
- Secure storage for contracts and agreements
- Document version control
- Search and filter capabilities
- Tag and categorize documents

**📤 Seamless Export**
- Export financial data in CSV format
- Ready for accountant review
- Customizable date ranges
- Category and tag filtering

**🤖 AI Assistant**
- Tailored insights into financial situations
- Spending pattern analysis
- Cost-cutting recommendations
- Document search and retrieval

**📈 Analytics & Reporting**
- Burn rate calculations
- Revenue and expense tracking
- Profit analysis
- Spending categorization
- Custom date range reports

---

## 🚀 Quick Start

```bash
# Clone your fork
git clone https://github.com/aiwithbenefits/midday_.git
cd midday_

# Install dependencies
bun install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your configuration

# Start Supabase (local development)
supabase start

# Start Redis (required for caching)
docker-compose up -d

# Start all services
bun run dev

# Or start individual services
bun run dev:dashboard  # Dashboard on http://localhost:3001
bun run dev:api        # API on http://localhost:3003
bun run dev:website    # Website on http://localhost:3000
```

---

## 📦 Installation

### Prerequisites

- **Node.js** 18+ or **Bun** 1.2+
- **Docker** & **Docker Compose** (for Redis and Supabase)
- **Supabase CLI** (for local development)
- **Git** (for version control)

### Step 1: Install Dependencies

```bash
# Using Bun (recommended)
bun install

# Or using npm
npm install
```

### Step 2: Install Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Linux/WSL
brew install supabase/tap/supabase

# Windows
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

### Step 3: Start Infrastructure Services

```bash
# Start Redis (required for caching)
docker-compose up -d

# Start Supabase (local development)
supabase start

# Note: Supabase will provide you with:
# - API URL: http://127.0.0.1:54321
# - DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
# - Studio URL: http://127.0.0.1:54323
# - Anon key: (save this for .env)
# - Service role key: (save this for .env)
```

### Step 4: Apply Database Migrations

```bash
# Navigate to Supabase directory
cd supabase

# Apply migrations
supabase db push

# Or apply custom migrations from apps/api/migrations
cd ../apps/api
supabase db execute -f migrations/0001_add_custom_functions.sql
supabase db execute -f migrations/0002_add_missing_tables.sql
# ... continue with other migrations as needed
```

---

## 🔧 Environment Setup

### Required Environment Variables

Create a `.env.local` file in the root directory with the following variables:

#### Supabase Configuration
```env
# Get these from `supabase start` output
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```

#### Application Settings
```env
NEXT_PUBLIC_APP_URL=http://localhost:3001
SECRET_KEY=your-secret-key-here

# For production
# NEXT_PUBLIC_APP_URL=https://your-domain.com
```

#### AI Features (Optional)
```env
# OpenAI for AI assistant features
OPENAI_API_KEY=sk-your-openai-key

# Gemini (alternative)
GEMINI_API_KEY=your-gemini-key

# Mistral (alternative)
MISTRAL_API_KEY=your-mistral-key
```

#### Email Service (Optional)
```env
# Resend for transactional emails
RESEND_API_KEY=re_your-resend-key
RESEND_AUDIENCE_ID=your-audience-id
```

#### Background Jobs (Optional)
```env
# Trigger.dev for background processing
TRIGGER_SECRET_KEY=your-trigger-key
```

#### Analytics (Optional)
```env
# OpenPanel for events and analytics
OPENPANEL_SECRET_KEY=your-openpanel-key
```

#### Redis Configuration
```env
# Redis for caching (started via docker-compose)
REDIS_URL=redis://localhost:6379
UPSTASH_REDIS_REST_URL=http://localhost:6379
UPSTASH_REDIS_REST_TOKEN=optional-token
```

### Per-Application Environment Files

Some apps may need their own `.env.local` files:

#### Dashboard (`apps/dashboard/.env.local`)
```env
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_APP_URL=http://localhost:3001
```

#### API (`apps/api/.env.local`)
```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
PORT=3003
```

---

## 🎬 Starting the Application

### Start All Services (Recommended)
```bash
bun run dev
```
This starts all services in parallel:
- Dashboard (http://localhost:3001)
- API (http://localhost:3003)
- Website (http://localhost:3000)

### Start Individual Services

```bash
# Dashboard only (recommended for development)
bun run dev:dashboard
# Access at: http://localhost:3001

# API only
bun run dev:api
# Access at: http://localhost:3003

# Website only
bun run dev:website
# Access at: http://localhost:3000

# Engine (processing)
bun run dev:engine

# Desktop app
bun run dev:desktop
```

### Production Build

```bash
# Build all applications
bun run build

# Build specific app
bun run build:dashboard

# Start production server
bun run start:dashboard  # Dashboard
bun run start:website    # Website
```

### Service Status Verification

```bash
# Check if services are running
curl http://localhost:3001  # Dashboard should respond
curl http://localhost:3003/health  # API health check
curl http://localhost:6379  # Redis (use redis-cli PING)
curl http://127.0.0.1:54321  # Supabase

# Check Supabase status
supabase status

# View Supabase Studio
open http://127.0.0.1:54323
```

---

## 🔌 API Endpoints

### Base URLs
- **Dashboard**: `http://localhost:3001`
- **API (tRPC)**: `http://localhost:3003/trpc`
- **Supabase**: `http://127.0.0.1:54321`

### tRPC API Endpoints

All API endpoints are accessible via tRPC at `http://localhost:3003/trpc`

#### Transactions
```typescript
// List transactions
GET /trpc/transactions.list

// Get single transaction
GET /trpc/transactions.get?id=<transaction-id>

// Create transaction
POST /trpc/transactions.create

// Update transaction
POST /trpc/transactions.update

// Delete transaction
POST /trpc/transactions.delete

// Bulk update transactions
POST /trpc/transactions.updateMany

// Search transactions
GET /trpc/transactions.search?query=<search-term>
```

#### Inbox (Document Management)
```typescript
// List inbox items
GET /trpc/inbox.list

// Get inbox item details
GET /trpc/inbox.get?id=<inbox-id>

// Update inbox item
POST /trpc/inbox.update

// Delete inbox item
POST /trpc/inbox.delete

// Link inbox item to transaction
POST /trpc/inbox.linkTransaction

// Upload document
POST /trpc/inbox.upload
```

#### Invoices
```typescript
// List invoices
GET /trpc/invoices.list

// Get invoice by ID
GET /trpc/invoices.get?id=<invoice-id>

// Create invoice
POST /trpc/invoices.create

// Update invoice
POST /trpc/invoices.update

// Delete invoice
POST /trpc/invoices.delete

// Update invoice status
POST /trpc/invoices.updateStatus

// Get invoice summary
GET /trpc/invoices.summary
```

#### Reports & Analytics
```typescript
// Get burn rate report
GET /trpc/reports.burnRate?from=<date>&to=<date>

// Get revenue report
GET /trpc/reports.revenue?from=<date>&to=<date>

// Get profit report
GET /trpc/reports.profit?from=<date>&to=<date>

// Get expense report
GET /trpc/reports.expenses?from=<date>&to=<date>

// Get spending report
GET /trpc/reports.spending?from=<date>&to=<date>&category=<slug>

// Get runway report
GET /trpc/reports.runway
```

#### Time Tracking
```typescript
// List tracker entries
GET /trpc/trackerEntries.list

// Create tracker entry
POST /trpc/trackerEntries.create

// Update tracker entry
POST /trpc/trackerEntries.update

// Delete tracker entry
POST /trpc/trackerEntries.delete

// Bulk create entries
POST /trpc/trackerEntries.createBulk

// Start timer
POST /trpc/tracker.start

// Stop timer
POST /trpc/tracker.stop

// Get current timer
GET /trpc/tracker.current

// Get timer status
GET /trpc/tracker.status
```

#### Projects
```typescript
// List tracker projects
GET /trpc/trackerProjects.list

// Create project
POST /trpc/trackerProjects.create

// Update project
POST /trpc/trackerProjects.update

// Delete project
POST /trpc/trackerProjects.delete

// Get project by ID
GET /trpc/trackerProjects.get?id=<project-id>
```

#### Customers
```typescript
// List customers
GET /trpc/customers.list

// Get customer by ID
GET /trpc/customers.get?id=<customer-id>

// Create customer
POST /trpc/customers.create

// Update customer
POST /trpc/customers.update

// Delete customer
POST /trpc/customers.delete

// Add tag to customer
POST /trpc/customers.addTag

// Remove tag from customer
POST /trpc/customers.removeTag
```

#### Documents (Vault)
```typescript
// List documents
GET /trpc/documents.list

// Get document by ID
GET /trpc/documents.get?id=<document-id>

// Get presigned URL for document
GET /trpc/documents.getPresignedUrl?id=<document-id>

// Delete document
POST /trpc/documents.delete

// Update document metadata
POST /trpc/documents.update
```

#### Tags
```typescript
// List all tags
GET /trpc/tags.list

// Create tag
POST /trpc/tags.create

// Update tag
POST /trpc/tags.update

// Delete tag
POST /trpc/tags.delete

// Get tag by ID
GET /trpc/tags.get?id=<tag-id>
```

#### Search
```typescript
// Global search across all entities
GET /trpc/search.global?query=<search-term>

// Search with filters
POST /trpc/search.advanced
```

#### Team & Users
```typescript
// Get current user
GET /trpc/user.current

// Update current user
POST /trpc/user.update

// Get team by ID
GET /trpc/team.get?id=<team-id>

// Update team
POST /trpc/team.update

// List team members
GET /trpc/team.members

// List all teams
GET /trpc/teams.list
```

#### Bank Accounts
```typescript
// List bank accounts
GET /trpc/bankAccounts.list

// Get bank account by ID
GET /trpc/bankAccounts.get?id=<account-id>

// Create bank account
POST /trpc/bankAccounts.create

// Update bank account
POST /trpc/bankAccounts.update

// Delete bank account
POST /trpc/bankAccounts.delete
```

### REST API Endpoints

#### File Proxy (Document Viewing)
```typescript
// Get document via proxy (handles PDF viewing)
GET /api/proxy?filePath=<path-to-file>

// Example:
GET /api/proxy?filePath=team-id/inbox-id/document.pdf
```

#### Health Check
```typescript
GET /api/health
```

---

## 🔄 Recent Modifications

This fork includes several critical fixes and enhancements:

### 1. PDF Viewer Fix (Critical)
**Issue**: PDFs were failing to load due to double "vault/" prefix in file paths

**Files Modified**:
- `apps/dashboard/src/components/inbox/inbox-details.tsx`
- `apps/dashboard/src/app/api/proxy/route.ts`
- `apps/dashboard/src/components/pdf-viewer.tsx`
- `apps/dashboard/src/components/file-viewer.tsx`

**Changes**:
- Fixed path construction to prevent `vault/vault/` duplication
- Enhanced proxy debugging with detailed logging
- Improved PDF viewer error handling
- Added binary file validation

**Documentation**: See `COMPLETE_PDF_FIX_SUMMARY.md`

### 2. Inbox Improvements
**Changes**:
- Enhanced document status handling
- Improved transaction linking
- Better error messages
- Added inbox item metadata display

**Files Modified**:
- `apps/dashboard/src/components/widgets/inbox/inbox-list.tsx`
- `apps/api/src/trpc/routers/inbox.ts`

### 3. Database Migrations
**Added Custom Migrations**:
- `0001_add_custom_functions.sql` - Core database functions
- `0002_add_missing_tables.sql` - OAuth and system tables
- `0003_add_missing_functions.sql` - Search and utility functions
- `0004_patch_categories.sql` - Category system enhancements
- `0005_patch_transactions.sql` - Transaction schema updates
- `0006_search_transactions_direct.sql` - Direct search implementation
- `0007_seed_demo_data.sql` - Demo data for testing
- `0008_add_invoice_template_columns.sql` - Invoice customization
- `0008_patch_inbox_status_enum.sql` - Inbox status handling

**Location**: `apps/api/migrations/`

### 4. Chart & Widget Fixes
**Issue**: React hydration errors on chart components

**Files Modified**:
- `apps/dashboard/src/components/charts/chart-period.tsx`
- `apps/dashboard/src/components/widgets/spending/spending-period.tsx`
- `apps/dashboard/src/components/widgets/spending/spending-category-list.tsx`
- `apps/dashboard/src/components/widgets/spending/spending-list.tsx`
- `apps/dashboard/src/components/charts/charts.tsx`
- `apps/dashboard/src/components/charts/empty-state.tsx`

**Changes**:
- Added client-side mount checks
- Fixed date formatting inconsistencies
- Resolved server/client hydration mismatches
- Removed blur overlay on charts

### 5. Configuration & Setup
**Added Files**:
- `docker-compose.yml` - Redis container setup
- `supabase/config.toml` - Supabase configuration
- `supabase/seed.sql` - Database seed data
- Multiple SQL utility files for manual database setup

**Documentation Added**:
- `PROJECT_SETUP_SUMMARY.md` - Complete setup guide
- `COMPLETE_PDF_FIX_SUMMARY.md` - PDF fix details
- `PDF_DEBUGGING_GUIDE.md` - Debugging procedures
- `TROUBLESHOOTING_STEPS.md` - Common issues
- `VERIFICATION_CHECKLIST.md` - Post-setup verification
- `FORK_MANAGEMENT_GUIDE.md` - Fork update procedures

### 6. Enhanced Error Handling & Logging
**Improvements across**:
- tRPC middleware and error boundaries
- API route error handling
- Client-side error logging
- Server console debugging output

---

## 🔱 Fork Management

This is a fork of the original Midday repository with custom modifications.

### Repository Setup

**Your Fork**: `https://github.com/aiwithbenefits/midday_`  
**Original Repo**: `https://github.com/midday-ai/midday`

### Remote Configuration

```bash
# Check your remotes
git remote -v

# Should show:
# origin    https://github.com/aiwithbenefits/midday_.git (fetch)
# origin    https://github.com/aiwithbenefits/midday_.git (push)
# upstream  https://github.com/midday-ai/midday.git (fetch)
# upstream  https://github.com/midday-ai/midday.git (push)
```

### Pushing Your Changes

```bash
# Stage your changes
git add .

# Commit with descriptive message
git commit -m "feat: your feature description"

# Push to YOUR fork (origin)
git push origin main
```

**Important**: Always push to `origin` (your fork), never to `upstream` (original repo).

### Pulling Updates from Original Repository

To get the latest changes from the original Midday repository without losing your modifications:

#### Option 1: Merge (Recommended)
```bash
# Fetch latest from original repo
git fetch upstream

# Merge updates into your main branch
git merge upstream/main

# Resolve any conflicts if they occur
# Then push merged changes to your fork
git push origin main
```

#### Option 2: Rebase
```bash
# Fetch latest from original repo
git fetch upstream

# Rebase your commits on top of upstream
git rebase upstream/main

# Force push to your fork (only after successful rebase)
git push --force origin main
```

### Handling Merge Conflicts

If you encounter conflicts when pulling from upstream:

```bash
# Git will show you which files have conflicts
git status

# Edit conflicting files
# Look for conflict markers: <<<<<<<, =======, >>>>>>>

# After resolving conflicts:
git add <resolved-files>
git commit -m "Merge upstream changes and resolve conflicts"
git push origin main
```

### Protection Guarantees

Your changes are protected because:
- ✅ Separate remote for original repo (`upstream`)
- ✅ You push to `origin` (your fork), pull from `upstream`
- ✅ Updates require explicit merge/rebase
- ✅ Git detects and notifies you of conflicts
- ✅ You control the merge process manually

**Complete Guide**: See `FORK_MANAGEMENT_GUIDE.md` for detailed procedures

---

## 🏗️ Architecture

### Technology Stack

**Frontend**:
- Next.js 15 (App Router)
- React 19
- TypeScript
- TailwindCSS
- Shadcn UI Components
- Framer Motion

**Backend**:
- tRPC (type-safe API)
- Hono (API framework)
- Supabase (database, storage, auth)
- Redis (caching)
- Bun runtime

**Desktop**:
- Tauri (native desktop app)

**Mobile**:
- Expo (React Native)

### Monorepo Structure

```
midday_/
├── apps/
│   ├── api/          # tRPC API server (Port 3003)
│   ├── dashboard/    # Main dashboard app (Port 3001)
│   ├── website/      # Marketing website (Port 3000)
│   ├── desktop/      # Tauri desktop app
│   ├── engine/       # Processing engine
│   └── docs/         # Documentation
├── packages/
│   ├── ui/           # Shared UI components
│   ├── supabase/     # Supabase client
│   ├── invoice/      # Invoice generation
│   ├── documents/    # Document processing
│   └── ...          # Other shared packages
└── supabase/         # Database migrations & config
```

### Infrastructure Services

**Database & Storage**:
- Supabase (PostgreSQL database)
- Supabase Storage (file storage)
- Supabase Auth (authentication)
- Supabase Realtime (live updates)

**Caching & Queue**:
- Redis (session & data caching)
- Upstash Redis (production alternative)

**Background Jobs**:
- Trigger.dev (scheduled tasks)

**Email**:
- Resend (transactional & marketing emails)

**AI/ML**:
- OpenAI (GPT models)
- Gemini (Google AI)
- Mistral (alternative LLM)

**Analytics**:
- OpenPanel (events & analytics)
- PostHog (product analytics - optional)

**Search**:
- Typesense (full-text search)
- PostgreSQL full-text search (built-in)

**Payment Processing**:
- Polar (payment processing)
- Stripe (alternative - optional)

**Bank Connections** (Optional):
- Plaid (US & Canada)
- Teller (US)
- GoCardLess (EU)

### Hosting Options

**Local Development**:
- Supabase CLI (local database)
- Docker Compose (Redis)
- Next.js dev server (dashboard)
- Bun dev server (API)

**Production Deployment**:
- Vercel (dashboard & website)
- Fly.io (API/tRPC)
- Supabase Cloud (database)
- Upstash (Redis)

---

## 📊 Manual Data Loading

For self-hosted deployments without bank connections, you can manually load data.

### Prerequisites

Connect to your Supabase database:
```bash
# Using psql
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres

# Or use Supabase Studio
open http://127.0.0.1:54323
```

### Step 1: Create a Team

```sql
INSERT INTO teams (id, name, email, created_at, updated_at) 
VALUES (
  'your-team-uuid-here',  -- Generate with: SELECT gen_random_uuid()
  'My Company',
  'contact@mycompany.com',
  NOW(),
  NOW()
);
```

### Step 2: Create a User (Optional)

```sql
INSERT INTO users (id, email, full_name, team_id, created_at) 
VALUES (
  'your-user-uuid-here',
  'you@mycompany.com',
  'Your Name',
  'your-team-uuid-here',
  NOW()
);
```

### Step 3: Load Transaction Data

```sql
INSERT INTO transactions (
  id,
  team_id,
  date,
  name,
  description,
  amount,
  currency,
  method,
  status,
  category_slug,
  internal_id,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'your-team-uuid-here',
  '2025-10-15',
  'Office Supplies - Staples',
  'Monthly office supply purchase',
  -150.50,
  'USD',
  'card_purchase',
  'posted',
  'office-supplies',
  'manual-txn-001',
  NOW(),
  NOW()
);
```

### Step 4: Create Categories

```sql
-- List available categories
SELECT slug, name, color FROM transaction_categories;

-- Or create custom category
INSERT INTO transaction_categories (slug, name, color, team_id)
VALUES ('consulting', 'Consulting', '#3B82F6', 'your-team-uuid-here');
```

### Step 5: Add Customers

```sql
INSERT INTO customers (
  id,
  team_id,
  name,
  email,
  phone,
  website,
  created_at
) VALUES (
  gen_random_uuid(),
  'your-team-uuid-here',
  'Acme Corporation',
  'billing@acme.com',
  '+1-555-0123',
  'https://acme.com',
  NOW()
);
```

### Step 6: Bulk Import from CSV

```sql
-- Create temporary table for CSV import
CREATE TEMP TABLE temp_transactions (
  date TEXT,
  name TEXT,
  amount TEXT,
  category TEXT
);

-- Import CSV file (adjust path to your file)
COPY temp_transactions(date, name, amount, category)
FROM '/path/to/transactions.csv'
DELIMITER ','
CSV HEADER;

-- Insert into transactions table
INSERT INTO transactions (
  id, team_id, date, name, amount, 
  currency, status, category_slug, internal_id, created_at
)
SELECT 
  gen_random_uuid(),
  'your-team-uuid-here',
  date::DATE,
  name,
  amount::NUMERIC,
  'USD',
  'posted',
  category,
  'csv-import-' || ROW_NUMBER() OVER (),
  NOW()
FROM temp_transactions;

-- Clean up
DROP TABLE temp_transactions;
```

### CSV Format Example

Create a `transactions.csv` file:
```csv
date,name,amount,category
2025-10-01,Office Rent,-2500.00,rent
2025-10-05,Client Payment,5000.00,income
2025-10-10,Software Subscription,-99.00,software
2025-10-15,Office Supplies,-150.50,office-supplies
```

### Using Supabase Studio

1. Open Supabase Studio: `http://127.0.0.1:54323`
2. Navigate to Table Editor
3. Select `transactions` table
4. Click "Insert" → "Insert row"
5. Fill in the form and save

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Supabase Connection Errors

**Error**: `Failed to connect to Supabase`

**Solutions**:
```bash
# Check if Supabase is running
supabase status

# Restart Supabase
supabase stop
supabase start

# Verify connection
curl http://127.0.0.1:54321/health
```

#### 2. Redis Connection Issues

**Error**: `Redis connection refused`

**Solutions**:
```bash
# Check if Redis is running
docker ps | grep redis

# Restart Redis
docker-compose restart redis

# Or start Redis
docker-compose up -d redis

# Test connection
redis-cli ping
# Should respond: PONG
```

#### 3. Port Already in Use

**Error**: `Port 3001 is already in use`

**Solutions**:
```bash
# Find process using the port (macOS/Linux)
lsof -ti:3001

# Kill the process
kill -9 $(lsof -ti:3001)

# Or use a different port
PORT=3002 bun run dev:dashboard
```

#### 4. Migration Errors

**Error**: `Migration failed` or `Table already exists`

**Solutions**:
```bash
# Reset database (WARNING: destroys all data)
supabase db reset

# Or apply specific migration
cd apps/api
supabase db execute -f migrations/0001_add_custom_functions.sql

# Check migration status
supabase migration list
```

#### 5. PDF Viewer Not Working

**Issue**: PDFs not loading in inbox

**Solutions**:
1. Check console for path errors
2. Verify file exists in Supabase Storage
3. Check `COMPLETE_PDF_FIX_SUMMARY.md` for details

```bash
# Enable detailed logging in proxy route
# Check: apps/dashboard/src/app/api/proxy/route.ts
# Logs will show file path, size, and validation
```

#### 6. Hydration Errors

**Error**: `Hydration failed` or `Text content does not match`

**Solutions**:
- Clear browser cache and reload
- Check date formatting in chart components
- Verify server/client time zones match
- See `PDF_DEBUGGING_GUIDE.md`

#### 7. Build Errors

**Error**: Build fails with TypeScript errors

**Solutions**:
```bash
# Clean all caches
bun run clean
bun run clean:workspaces

# Reinstall dependencies
rm -rf node_modules
rm bun.lock
bun install

# Type check
bun run typecheck
```

#### 8. Environment Variable Issues

**Error**: `Environment variable not found`

**Solutions**:
```bash
# Check if .env.local exists
ls -la .env.local

# Verify variable names match exactly
# Some variables need NEXT_PUBLIC_ prefix for client-side

# Restart development server after changes
# Ctrl+C then: bun run dev
```

### Debug Mode

Enable verbose logging:

```bash
# In .env.local
DEBUG=*
LOG_LEVEL=debug
NODE_ENV=development

# Start with verbose output
bun run dev 2>&1 | tee debug.log
```

### Getting Help

1. **Check Documentation Files**:
   - `PROJECT_SETUP_SUMMARY.md`
   - `TROUBLESHOOTING_STEPS.md`
   - `VERIFICATION_CHECKLIST.md`

2. **Check Logs**:
   - Browser Console (F12)
   - Terminal output
   - Supabase logs: `supabase logs`

3. **Community Support**:
   - [Discord](https://go.midday.ai/anPiuRx)
   - [GitHub Issues](https://github.com/midday-ai/midday/issues)

---
## 🛠️ Development Workflow

### Code Quality

```bash
# Format code
bun run format

# Lint code
bun run lint

# Fix linting issues
bun run lint:fix

# Type check
bun run typecheck
```

### Testing

```bash
# Run all tests
bun run test

# Run tests in watch mode
bun run test:watch

# Test specific app
cd apps/dashboard
bun test
```

### Building

```bash
# Build all apps
bun run build

# Build specific app
bun run build:dashboard

# Clean build artifacts
bun run clean:workspaces
```

### Database Management

```bash
# Create new migration
supabase migration new migration_name

# Apply migrations
supabase db push

# Reset database (WARNING: destroys data)
supabase db reset

# Dump database schema
supabase db dump -f schema.sql

# View database
supabase db studio
```

### Deployment Checklist

Before deploying to production:

- [ ] All tests passing
- [ ] No TypeScript errors
- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] Redis connection configured
- [ ] Supabase project created
- [ ] Build succeeds locally
- [ ] Error tracking configured (Sentry)

---

## 📚 Additional Resources

### Documentation Files

- **Setup**: `PROJECT_SETUP_SUMMARY.md`
- **PDF Fixes**: `COMPLETE_PDF_FIX_SUMMARY.md`
- **Debugging**: `PDF_DEBUGGING_GUIDE.md`
- **Troubleshooting**: `TROUBLESHOOTING_STEPS.md`
- **Fork Management**: `FORK_MANAGEMENT_GUIDE.md`
- **Verification**: `VERIFICATION_CHECKLIST.md`

### External Documentation

- **Official Docs**: https://docs.midday.ai
- **Supabase Docs**: https://supabase.com/docs
- **Next.js Docs**: https://nextjs.org/docs
- **tRPC Docs**: https://trpc.io/docs

### Useful Commands Reference

```bash
# Quick reference
bun run dev               # Start all services
bun run dev:dashboard     # Dashboard only
bun run dev:api          # API only
supabase start           # Start Supabase
supabase status          # Check Supabase status
docker-compose up -d     # Start Redis
git fetch upstream       # Get upstream updates
git merge upstream/main  # Merge upstream changes
```

---
## 🤝 Contributing

This is a personal fork with custom modifications. For contributing to the original project:

1. Visit the [original repository](https://github.com/midday-ai/midday)
2. Read their contribution guidelines
3. Submit issues and pull requests there

For this fork:
- Issues and improvements specific to this fork can be tracked here
- Major changes should be documented in the changelog
- Always test thoroughly before committing

---

## 📄 License

This project is licensed under **AGPL-3.0** for non-commercial use.

### Commercial Use

For commercial use or deployments requiring a setup fee, contact the original maintainers at [engineer@midday.ai](mailto:engineer@midday.ai) for a commercial license.

By using this software, you agree to the terms of the license.

### Original Project

This is a fork of [Midday](https://github.com/midday-ai/midday) by Midday AI.

All credits for the original codebase go to the Midday team.

---

## 📊 Repository Activity

![Alt](https://repobeats.axiom.co/api/embed/96aae855e5dd87c30d53c1d154b37cf7aa5a89b3.svg "Repobeats analytics image")

---

## 🎯 Quick Links

- **Dashboard**: http://localhost:3001
- **API**: http://localhost:3003
- **Supabase Studio**: http://127.0.0.1:54323
- **Redis**: localhost:6379

- **Your Fork**: https://github.com/aiwithbenefits/midday_
- **Original Repo**: https://github.com/midday-ai/midday
- **Documentation**: https://docs.midday.ai
- **Discord**: https://go.midday.ai/anPiuRx

---

## 📝 Version Information

**Current Version**: 1.0.0 (Custom Fork)  
**Base Version**: Midday v1.x  
**Last Updated**: October 2025  
**Node.js**: 18+  
**Bun**: 1.2.21+

---

## ⚠️ Important Notes

1. **This is a customized fork** - Not all features from the original may work the same way
2. **Self-hosted deployment** - Designed for local/private hosting
3. **No bank connections** - Manual data loading workflow
4. **Authentication bypassed** - Direct dashboard access
5. **All AI features intact** - Full analytics and intelligence preserved
6. **Active development** - Check commit history for latest changes

---

## 🔐 Security

- Never commit `.env.local` or secrets to Git
- Use environment variables for all sensitive data
- Keep Supabase service role key secure
- Enable RLS policies on all tables in production
- Use HTTPS in production deployments
- Regularly update dependencies

---

## 💡 Tips

- Use `bun` instead of `npm` for faster installs
- Enable Turbopack for faster dev builds (already enabled)
- Check browser console for client-side errors
- Check terminal for server-side errors
- Use Supabase Studio for database inspection
- Keep documentation files updated with changes

---

**Happy coding! 🚀**

For questions specific to this fork, refer to the documentation files or check the commit history for implementation details.
