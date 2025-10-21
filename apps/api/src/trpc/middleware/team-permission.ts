import type { Session } from "@api/utils/auth";
import { teamCache } from "@midday/cache/team-cache";
import type { Database } from "@midday/db/client";
import { TRPCError } from "@trpc/server";

export const withTeamPermission = async <TReturn>(opts: {
  ctx: {
    session?: Session | null;
    db: Database;
  };
  next: (opts: {
    ctx: {
      session?: Session | null;
      db: Database;
      teamId: string | null;
    };
  }) => Promise<TReturn>;
}) => {
  const { ctx, next } = opts;

  const userId = ctx.session?.user?.id;

  if (!userId) {
    throw new TRPCError({
      code: "UNAUTHORIZED",
      message: "No permission to access this team",
    });
  }

  // Self-hosted mode: Just get the user's team_id without permission checks
  const result = await ctx.db.query.users.findFirst({
    columns: {
      teamId: true,
    },
    where: (users, { eq }) => eq(users.id, userId),
  });

  if (!result) {
    throw new TRPCError({
      code: "NOT_FOUND",
      message: "User not found",
    });
  }

  const teamId = result.teamId;

  // Self-hosted: Always allow access for authenticated users
  return next({
    ctx: {
      session: ctx.session,
      teamId,
      db: ctx.db,
    },
  });
};
