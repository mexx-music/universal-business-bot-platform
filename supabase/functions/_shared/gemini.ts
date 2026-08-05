import { ApiError } from "./errors.ts";
import type { ValidatedRequest } from "./validate.ts";

// Minimal fetch shape so the module is testable with a fake fetch (no network).
export type FetchLike = (
  url: string,
  init: {
    method: string;
    headers: Record<string, string>;
    body: string;
    signal?: AbortSignal;
  },
) => Promise<{
  ok: boolean;
  status: number;
  json: () => Promise<unknown>;
}>;

export interface GeminiRequestBody {
  contents: { role: string; parts: { text: string }[] }[];
  systemInstruction?: { parts: { text: string }[] };
  generationConfig: { maxOutputTokens: number };
}

export interface NeutralResponse {
  text: string;
  model: string;
  finishReason: string;
  usage: { inputTokens: number; outputTokens: number; totalTokens: number };
}

const GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta";
const NORMALISED_FINISH = new Set([
  "STOP",
  "MAX_TOKENS",
  "SAFETY",
  "RECITATION",
  "OTHER",
]);

/**
 * Maps the neutral, validated request to the Gemini REST body.
 * - system messages -> systemInstruction
 * - assistant -> "model", user -> "user"
 * - NO sampling parameters (temperature/top_p/top_k) for gemini-3.6-flash.
 */
export function buildGeminiRequest(v: ValidatedRequest): GeminiRequestBody {
  const systemParts: { text: string }[] = [];
  const contents: GeminiRequestBody["contents"] = [];
  for (const m of v.messages) {
    if (m.role === "system") {
      systemParts.push({ text: m.content });
    } else {
      contents.push({
        role: m.role === "assistant" ? "model" : "user",
        parts: [{ text: m.content }],
      });
    }
  }
  const body: GeminiRequestBody = {
    contents,
    generationConfig: { maxOutputTokens: v.maxTokens },
  };
  if (systemParts.length > 0) {
    body.systemInstruction = { parts: systemParts };
  }
  return body;
}

/** Calls Gemini with a server timeout via AbortController. The key is sent as
 * a header (never in the URL) and never logged. Throws typed ApiError. */
export async function callGemini(
  fetchImpl: FetchLike,
  apiKey: string,
  model: string,
  body: GeminiRequestBody,
  timeoutMs: number,
): Promise<unknown> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  let res: Awaited<ReturnType<FetchLike>>;
  try {
    res = await fetchImpl(
      `${GEMINI_BASE}/models/${model}:generateContent`,
      {
        method: "POST",
        headers: {
          "content-type": "application/json",
          "x-goog-api-key": apiKey,
        },
        body: JSON.stringify(body),
        signal: controller.signal,
      },
    );
  } catch (e) {
    if (e instanceof Error && e.name === "AbortError") {
      throw new ApiError("upstream_timeout", "Upstream timed out");
    }
    throw new ApiError("upstream_unavailable", "Upstream request failed");
  } finally {
    clearTimeout(timer);
  }

  if (res.status === 429) {
    throw new ApiError("rate_limited", "Upstream rate limited");
  }
  if (res.status === 401 || res.status === 403) {
    throw new ApiError("unauthorized", "Upstream rejected credentials");
  }
  if (!res.ok) {
    throw new ApiError("upstream_unavailable", "Upstream error");
  }
  try {
    return await res.json();
  } catch {
    throw new ApiError("malformed_upstream_response", "Bad upstream JSON");
  }
}

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null && !Array.isArray(v);
}

/** Maps a Gemini JSON response to the neutral response. Blocked/empty results
 * raise content_blocked — never a false success. */
export function mapGeminiResponse(
  json: unknown,
  model: string,
): NeutralResponse {
  if (!isObject(json)) {
    throw new ApiError("malformed_upstream_response", "Unexpected response");
  }

  // Prompt-level block (no candidates at all).
  const promptFeedback = json.promptFeedback;
  if (isObject(promptFeedback) && typeof promptFeedback.blockReason === "string") {
    throw new ApiError("content_blocked", "Prompt blocked upstream");
  }

  const candidates = json.candidates;
  if (!Array.isArray(candidates) || candidates.length === 0) {
    throw new ApiError("content_blocked", "No candidates returned");
  }
  const first = candidates[0];
  if (!isObject(first)) {
    throw new ApiError("malformed_upstream_response", "Bad candidate");
  }

  const rawFinish = typeof first.finishReason === "string"
    ? first.finishReason.toUpperCase()
    : "OTHER";
  const finishReason = NORMALISED_FINISH.has(rawFinish) ? rawFinish : "OTHER";

  const content = first.content;
  let text = "";
  if (isObject(content) && Array.isArray(content.parts)) {
    text = content.parts
      .map((p) => (isObject(p) && typeof p.text === "string" ? p.text : ""))
      .join("");
  }

  // A safety/recitation stop with no text is a block, not a success.
  if (text.length === 0 && (finishReason === "SAFETY" || finishReason === "RECITATION")) {
    throw new ApiError("content_blocked", "Response blocked upstream");
  }
  if (text.length === 0 && finishReason !== "MAX_TOKENS") {
    throw new ApiError("content_blocked", "Empty response");
  }

  const usageMeta = isObject(json.usageMetadata) ? json.usageMetadata : {};
  const inputTokens = numberOr(usageMeta.promptTokenCount, 0);
  const outputTokens = numberOr(usageMeta.candidatesTokenCount, 0);
  const totalTokens = numberOr(
    usageMeta.totalTokenCount,
    inputTokens + outputTokens,
  );

  return {
    text,
    model,
    finishReason,
    usage: { inputTokens, outputTokens, totalTokens },
  };
}

function numberOr(v: unknown, fallback: number): number {
  return typeof v === "number" && Number.isFinite(v) ? v : fallback;
}
