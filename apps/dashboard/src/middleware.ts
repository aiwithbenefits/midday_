import { updateSession } from "@midday/supabase/middleware";
import { createClient } from "@midday/supabase/server";
import { createI18nMiddleware } from "next-international/middleware";
import { type NextRequest, NextResponse } from "next/server";

const I18nMiddleware = createI18nMiddleware({
  locales: ["en"],
  defaultLocale: "en",
  urlMappingStrategy: "rewrite",
});

export async function middleware(request: NextRequest) {
  const response = await updateSession(request, I18nMiddleware(request));
  
  // Self-hosted: Skip all authentication checks - allow all requests
  return response;
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|api).*)"],
};
