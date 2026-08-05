// CORS is handled centrally via a configurable allowlist (ALLOWED_ORIGINS).
// Production must never use a blanket "*"; only clearly-marked local dev may
// fall back to localhost origins.

const LOCAL_DEV_ORIGINS = [
  "http://localhost",
  "http://127.0.0.1",
];

/** Parses ALLOWED_ORIGINS (comma-separated). Empty => local-dev fallback. */
export function parseAllowedOrigins(raw: string | undefined): string[] {
  const list = (raw ?? "")
    .split(",")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
  return list.length > 0 ? list : LOCAL_DEV_ORIGINS;
}

/** True when an incoming Origin is permitted (exact or localhost-prefix). */
export function isOriginAllowed(
  origin: string | null,
  allowed: string[],
): boolean {
  if (!origin) return false;
  return allowed.some((a) =>
    a === origin ||
    // Localhost dev entries match any port.
    ((a === "http://localhost" || a === "http://127.0.0.1") &&
      origin.startsWith(`${a}:`))
  );
}

/** CORS headers echoing the origin only when allow-listed; else omitted. */
export function corsHeaders(
  origin: string | null,
  allowed: string[],
): Record<string, string> {
  const headers: Record<string, string> = {
    "Vary": "Origin",
    "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
    // Exactly the headers the Supabase browser client sends on functions.invoke
    // (Authorization + apikey for auth, x-client-info for the SDK), plus the
    // JSON content-type. No dynamic mirroring of arbitrary request headers.
    "Access-Control-Allow-Headers": "authorization, apikey, x-client-info, content-type",
    "Access-Control-Max-Age": "600",
  };
  if (isOriginAllowed(origin, allowed)) {
    headers["Access-Control-Allow-Origin"] = origin as string;
  }
  return headers;
}
