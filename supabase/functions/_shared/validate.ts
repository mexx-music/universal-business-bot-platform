import {
  ALLOWED_PROVIDER,
  ALLOWED_ROLES,
  clampMaxTokens,
  LIMITS,
  resolveModel,
} from "./config.ts";
import { ApiError } from "./errors.ts";

export interface NeutralMessage {
  role: string;
  content: string;
}

/** A strictly validated, server-normalised request. Only known, safe fields
 * survive — unknown/dangerous fields (incl. sampling params and metadata) are
 * never carried forward to the upstream call. */
export interface ValidatedRequest {
  action: "generate" | "ping";
  model: string;
  maxTokens: number;
  messages: NeutralMessage[];
  totalChars: number;
}

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null && !Array.isArray(v);
}

/**
 * Validates the neutral transport payload (the exact shape the Flutter
 * AiTransport sends). Throws ApiError('invalid_request') on any problem.
 * The single canonical model field is `model` (allow-list-checked hint).
 */
export function validate(bodyUnknown: unknown): ValidatedRequest {
  if (!isObject(bodyUnknown)) {
    throw new ApiError("invalid_request", "Body must be a JSON object");
  }
  const body = bodyUnknown;

  const action = body.action === undefined ? "generate" : body.action;
  if (action !== "generate" && action !== "ping") {
    throw new ApiError("invalid_request", "Unsupported action");
  }

  if (body.provider !== ALLOWED_PROVIDER) {
    throw new ApiError("invalid_request", "Unsupported provider");
  }

  // Model hint is checked against the server allowlist (never free-override).
  const model = resolveModel(body.model);
  const maxTokens = clampMaxTokens(body.maxTokens);

  if (action === "ping") {
    return { action, model, maxTokens, messages: [], totalChars: 0 };
  }

  const rawMessages = body.messages;
  if (!Array.isArray(rawMessages) || rawMessages.length === 0) {
    throw new ApiError("invalid_request", "At least one message is required");
  }
  if (rawMessages.length > LIMITS.maxMessages) {
    throw new ApiError("invalid_request", "Too many messages");
  }

  const messages: NeutralMessage[] = [];
  let totalChars = 0;
  for (const m of rawMessages) {
    if (!isObject(m)) {
      throw new ApiError("invalid_request", "Malformed message");
    }
    const role = m.role;
    const content = m.content;
    if (typeof role !== "string" || !ALLOWED_ROLES.has(role)) {
      throw new ApiError("invalid_request", "Invalid message role");
    }
    if (typeof content !== "string" || content.length === 0) {
      throw new ApiError("invalid_request", "Empty message content");
    }
    if (content.length > LIMITS.maxMessageChars) {
      throw new ApiError("invalid_request", "Message too long");
    }
    totalChars += content.length;
    if (totalChars > LIMITS.maxTotalChars) {
      throw new ApiError("invalid_request", "Total input too large");
    }
    messages.push({ role, content });
  }

  const hasNonSystem = messages.some((m) => m.role !== "system");
  if (!hasNonSystem) {
    throw new ApiError("invalid_request", "A user message is required");
  }

  return { action, model, maxTokens, messages, totalChars };
}
