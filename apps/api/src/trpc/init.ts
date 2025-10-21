import { createClient } from "@api/services/supabase";
import { verifyAccessToken } from "@api/utils/auth";
import type { Session } from "@api/utils/auth";
import { getGeoContext } from "@api/utils/geo";
import type { Database } from "@midday/db/client";
import { db } from "@midday/db/client";
import type { SupabaseClient } from "@supabase/supabase-js";
import { TRPCError, initTRPC } from "@trpc/server";
import type { Context } from "hono";
import superjson from "superjson";
import { withPrimaryReadAfterWrite } from "./middleware/primary-read-after-write";

type TRPCContext = {
  session: Session | null;
  supabase: SupabaseClient;
  db: Database;
  geo: ReturnType<typeof getGeoContext>;
  teamId?: string;
};

export const createTRPCContext = async (
  _: unknown,
  c: Context,
): Promise<TRPCContext> => {
  const accessToken = c.req.header("Authorization")?.split(" ")[1];
  const session = await verifyAccessToken(accessToken);
  const supabase = await createClient(accessToken);

  // Use the singleton database instance - no need for caching
  const geo = getGeoContext(c.req);

  return {
    session,
    supabase,
    db,
    geo,
  };
};

const t = initTRPC.context<TRPCContext>().create({
  transformer: superjson,
});

export const createTRPCRouter = t.router;
export const createCallerFactory = t.createCallerFactory;

const withPrimaryDbMiddleware = t.middleware(async (opts) => {
  return withPrimaryReadAfterWrite({
    ctx: opts.ctx,
    type: opts.type,
    next: opts.next,
  });
});

export const publicProcedure = t.procedure.use(withPrimaryDbMiddleware);

// Self-hosted: No authentication required - all procedures are public
export const protectedProcedure = t.procedure
  .use(withPrimaryDbMiddleware)
  .use(async (opts) => {
    // Self-hosted: Hardcoded session and team - no database queries
    const fakeSession = {
      user: {
        id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        email: 'admin@local.dev',
        full_name: 'Local Admin',
      },
    };

    const teamId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

    return opts.next({
      ctx: {
        teamId,
        session: fakeSession,
      },
    });
  });
