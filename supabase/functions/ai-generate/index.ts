// ai-generate: runtime entry point.
//
// This file only wires the real Deno environment into the testable pipeline in
// handler.ts and starts the server. All request logic lives in handler.ts so it
// can be unit-tested with fakes and no network (importing this file would start
// the server, so tests import handler.ts instead).
//
// Future demo-protection extension points (NOT implemented here — would need
// external infra/secrets): per-IP / per-session rate limiting, Cloudflare
// Turnstile verification, a global daily demo quota, and abuse detection.
// They hook in right after CORS/method checks in handler.ts.

import { type Deps, handleRequest } from "./handler.ts";
import type { FetchLike } from "../_shared/gemini.ts";

declare const Deno: {
  env: { get: (k: string) => string | undefined };
  serve: (handler: (req: Request) => Promise<Response>) => void;
};

Deno.serve((req: Request) =>
  handleRequest(req, {
    env: (k) => Deno.env.get(k),
    fetchImpl: globalThis.fetch as unknown as FetchLike,
    requestId: () => crypto.randomUUID(),
    now: () => Date.now(),
  } as Deps)
);
