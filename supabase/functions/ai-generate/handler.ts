// ai-generate handler: vendor-neutral, server-side Gemini gateway (pure logic).
//
// The Flutter client (via AiTransport) POSTs the neutral transport payload;
// this function validates it, calls Gemini server-side with the key from
// GEMINI_API_KEY (env only), and returns the neutral AiTransportResponse
// shape. The API key never reaches the client, is never logged, and the model
// is chosen server-side (client hints are allow-list-checked only).
//
// The request pipeline lives here in `handleRequest(req, deps)` with injectable
// env/fetch/id/clock, so unit tests exercise it with a fake fetch and no
// network. The real Deno runtime is wired in index.ts (top-level Deno.serve),
// which imports this module — keeping this file free of import-time side
// effects so it is safe to import from tests.

import { corsHeaders, parseAllowedOrigins } from "../_shared/cors.ts";
import { DEFAULT_MODEL } from "../_shared/config.ts";
import { ApiError, type ErrorCode } from "../_shared/errors.ts";
import {
  buildGeminiRequest,
  callGemini,
  type FetchLike,
  mapGeminiResponse,
} from "../_shared/gemini.ts";
import { validate } from "../_shared/validate.ts";

const UPSTREAM_TIMEOUT_MS = 20_000;

export interface Deps {
  env: (key: string) => string | undefined;
  fetchImpl: FetchLike;
  requestId: () => string;
  now: () => number;
  // Structured, data-minimal logger. Never receives content or secrets.
  log?: (entry: Record<string, unknown>) => void;
}

export async function handleRequest(
  req: Request,
  deps: Deps,
): Promise<Response> {
  const requestId = deps.requestId();
  const startedAt = deps.now();
  const origin = req.headers.get("Origin");
  const allowed = parseAllowedOrigins(deps.env("ALLOWED_ORIGINS"));
  const cors = corsHeaders(origin, allowed);

  const respond = (
    status: number,
    payload: Record<string, unknown>,
    event: string,
    extra: Record<string, unknown> = {},
  ): Response => {
    (deps.log ?? defaultLog)({
      level: status >= 500 ? "error" : status >= 400 ? "warn" : "info",
      requestId,
      event,
      method: req.method,
      status,
      durationMs: deps.now() - startedAt,
      ...extra,
    });
    return new Response(JSON.stringify(payload), {
      status,
      headers: {
        ...cors,
        "content-type": "application/json",
        "x-request-id": requestId,
      },
    });
  };

  const fail = (code: ErrorCode, event: string): Response =>
    respond(
      new ApiError(code, code).status,
      {
        error: { code, message: clientMessage(code), requestId },
      },
      event,
      { code },
    );

  // --- CORS preflight ---
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }

  // --- Ping (GET): never calls Gemini ---
  if (req.method === "GET") {
    return respond(200, {
      ok: true,
      provider: "googleGemini",
      model: DEFAULT_MODEL,
      requestId,
    }, "ping");
  }

  if (req.method !== "POST") {
    return fail("invalid_request", "method_not_allowed");
  }

  const contentType = req.headers.get("content-type") ?? "";
  if (!contentType.toLowerCase().includes("application/json")) {
    return fail("invalid_request", "bad_content_type");
  }

  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return fail("invalid_request", "malformed_json");
  }

  try {
    const validated = validate(body);

    // POST ping variant: also free of any Gemini call.
    if (validated.action === "ping") {
      return respond(200, {
        ok: true,
        provider: "googleGemini",
        model: validated.model,
        requestId,
      }, "ping");
    }

    const apiKey = deps.env("GEMINI_API_KEY");
    if (!apiKey || apiKey.length === 0) {
      return fail("missing_server_configuration", "missing_key");
    }

    const geminiBody = buildGeminiRequest(validated);
    const raw = await callGemini(
      deps.fetchImpl,
      apiKey,
      validated.model,
      geminiBody,
      UPSTREAM_TIMEOUT_MS,
    );
    const mapped = mapGeminiResponse(raw, validated.model);

    return respond(
      200,
      {
        text: mapped.text,
        model: mapped.model,
        finishReason: mapped.finishReason,
        usage: {
          inputTokens: mapped.usage.inputTokens,
          outputTokens: mapped.usage.outputTokens,
          totalTokens: mapped.usage.totalTokens,
        },
        requestId,
      },
      "generate_ok",
      {
        model: mapped.model,
        msgCount: validated.messages.length,
        totalChars: validated.totalChars,
        finishReason: mapped.finishReason,
      },
    );
  } catch (e) {
    if (e instanceof ApiError) {
      return fail(e.code, "handled_error");
    }
    // Never leak stack/details to the client.
    (deps.log ?? defaultLog)({
      level: "error",
      requestId,
      event: "unhandled_error",
      durationMs: deps.now() - startedAt,
    });
    return fail("internal_error", "unhandled_error");
  }
}

// Client-safe, generic messages (no upstream detail, no secrets).
function clientMessage(code: ErrorCode): string {
  switch (code) {
    case "invalid_request":
      return "The request was invalid.";
    case "unauthorized":
      return "The AI service rejected the request.";
    case "missing_server_configuration":
      return "The AI service is not configured.";
    case "rate_limited":
      return "Too many requests. Please try again later.";
    case "upstream_timeout":
      return "The AI service timed out.";
    case "upstream_unavailable":
      return "The AI service is currently unavailable.";
    case "content_blocked":
      return "The response was blocked by safety filters.";
    case "malformed_upstream_response":
      return "The AI service returned an unexpected response.";
    case "internal_error":
      return "An internal error occurred.";
  }
}

function defaultLog(entry: Record<string, unknown>): void {
  // Structured JSON line; contains no content and no secrets by construction.
  console.log(JSON.stringify(entry));
}
