// Stable, machine-readable error contract. The client never receives stack
// traces, secrets or raw upstream bodies — only { code, message, requestId }.

export type ErrorCode =
  | "invalid_request"
  | "unauthorized"
  | "missing_server_configuration"
  | "rate_limited"
  | "upstream_timeout"
  | "upstream_unavailable"
  | "content_blocked"
  | "malformed_upstream_response"
  | "internal_error";

export const ERROR_STATUS: Record<ErrorCode, number> = {
  invalid_request: 400,
  unauthorized: 401,
  missing_server_configuration: 500,
  rate_limited: 429,
  upstream_timeout: 504,
  upstream_unavailable: 502,
  content_blocked: 422,
  malformed_upstream_response: 502,
  internal_error: 500,
};

/** An error with a stable code and a client-safe message (never a secret). */
export class ApiError extends Error {
  constructor(public readonly code: ErrorCode, message: string) {
    super(message);
    this.name = "ApiError";
  }

  get status(): number {
    return ERROR_STATUS[this.code];
  }
}
