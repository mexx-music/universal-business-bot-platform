// Central, server-controlled configuration for the ai-generate function.
// Limits are intentionally small for a demo endpoint that must later run
// without login. If BusinessBrain features need smaller limits, lower these.

export const LIMITS = {
  maxMessages: 20,
  maxMessageChars: 8_000,
  maxTotalChars: 30_000,
  // Demo output cap; the client can request less but never more.
  maxOutputTokens: 2_048,
} as const;

// The model is chosen server-side. A client hint is only honoured if it is on
// this allowlist; otherwise the fixed default wins. Sampling parameters
// (temperature/top_p/top_k) are deliberately NOT sent for gemini-3.6-flash.
export const DEFAULT_MODEL = "gemini-3.6-flash";
export const MODEL_ALLOWLIST: ReadonlySet<string> = new Set(["gemini-3.6-flash"]);

// This function serves only the Gemini provider.
export const ALLOWED_PROVIDER = "googleGemini";

// Roles accepted from the neutral transport (tight demo surface).
export const ALLOWED_ROLES: ReadonlySet<string> = new Set([
  "system",
  "user",
  "assistant",
]);

/** Resolves the effective model: a client hint only if allow-listed. */
export function resolveModel(hint?: unknown): string {
  return typeof hint === "string" && MODEL_ALLOWLIST.has(hint)
    ? hint
    : DEFAULT_MODEL;
}

/** Clamps requested output tokens into [1, maxOutputTokens]. */
export function clampMaxTokens(value?: unknown): number {
  const n = typeof value === "number" && Number.isFinite(value)
    ? Math.floor(value)
    : LIMITS.maxOutputTokens;
  return Math.max(1, Math.min(n, LIMITS.maxOutputTokens));
}
