// Unit tests for the ai-generate pipeline. No network: a fake fetch is
// injected. Run locally with: `deno test --allow-none supabase/functions`.
//
// NOTE: These tests were authored without a local Deno runtime available and
// therefore have not been executed in CI/dev yet (see GEMINI_EDGE_FUNCTION.md).

import {
  assert,
  assertEquals,
  assertFalse,
} from "https://deno.land/std@0.224.0/assert/mod.ts";
import { handleRequest, type Deps } from "../ai-generate/index.ts";
import type { FetchLike } from "../_shared/gemini.ts";

const KEY_SENTINEL = "SECRET-KEY-SENTINEL-DO-NOT-LEAK";

interface FakeFetch {
  impl: FetchLike;
  calls: number;
  lastUrl: string | null;
  lastBody: Record<string, unknown> | null;
  lastHeaders: Record<string, string> | null;
}

function fakeFetch(
  handler: (url: string) => { ok: boolean; status: number; json: () => Promise<unknown> } | Promise<never>,
): FakeFetch {
  const state: FakeFetch = {
    calls: 0,
    lastUrl: null,
    lastBody: null,
    lastHeaders: null,
    impl: async (url, init) => {
      state.calls++;
      state.lastUrl = url;
      state.lastHeaders = init.headers;
      state.lastBody = JSON.parse(init.body) as Record<string, unknown>;
      const out = handler(url);
      return await out;
    },
  };
  return state;
}

function ok(json: unknown) {
  return { ok: true, status: 200, json: () => Promise.resolve(json) };
}

function geminiOk(text: string, finishReason = "STOP", usage = {
  promptTokenCount: 10,
  candidatesTokenCount: 5,
  totalTokenCount: 15,
}) {
  return ok({
    candidates: [{
      content: { parts: [{ text }] },
      finishReason,
    }],
    usageMetadata: usage,
  });
}

function deps(overrides: Partial<Deps> & { fetch?: FakeFetch } = {}): {
  d: Deps;
  logs: Record<string, unknown>[];
} {
  const logs: Record<string, unknown>[] = [];
  const d: Deps = {
    env: overrides.env ?? ((k) => (k === "GEMINI_API_KEY" ? KEY_SENTINEL : undefined)),
    fetchImpl: overrides.fetch?.impl ??
      fakeFetch(() => geminiOk("hello")).impl,
    requestId: () => "req-test-1",
    now: () => 1000,
    log: (e) => logs.push(e),
  };
  return { d, logs };
}

function post(body: unknown, contentType = "application/json"): Request {
  return new Request("http://localhost/ai-generate", {
    method: "POST",
    headers: { "content-type": contentType },
    body: JSON.stringify(body),
  });
}

const validBody = {
  provider: "googleGemini",
  messages: [
    { role: "system", content: "Be concise." },
    { role: "user", content: "Hallo" },
  ],
};

// 1. valid neutral request
Deno.test("valid request returns mapped text", async () => {
  const ff = fakeFetch(() => geminiOk("Hallo zurück"));
  const { d } = deps({ fetch: ff });
  const res = await handleRequest(post(validBody), d);
  assertEquals(res.status, 200);
  const json = await res.json();
  assertEquals(json.text, "Hallo zurück");
  assertEquals(json.model, "gemini-3.6-flash");
  assertEquals(json.finishReason, "STOP");
});

// 2. invalid method
Deno.test("invalid method is rejected", async () => {
  const { d } = deps();
  const req = new Request("http://localhost/ai-generate", { method: "PUT" });
  const res = await handleRequest(req, d);
  assertEquals(res.status, 400);
  assertEquals((await res.json()).error.code, "invalid_request");
});

// 3. wrong content-type
Deno.test("wrong content-type is rejected", async () => {
  const { d } = deps();
  const res = await handleRequest(post(validBody, "text/plain"), d);
  assertEquals(res.status, 400);
});

// 4. missing messages
Deno.test("missing messages is rejected", async () => {
  const { d } = deps();
  const res = await handleRequest(post({ provider: "googleGemini" }), d);
  assertEquals(res.status, 400);
});

// 5. too many messages
Deno.test("too many messages is rejected", async () => {
  const { d } = deps();
  const messages = Array.from({ length: 21 }, () => ({ role: "user", content: "x" }));
  const res = await handleRequest(post({ provider: "googleGemini", messages }), d);
  assertEquals(res.status, 400);
});

// 6. message too long
Deno.test("message too long is rejected", async () => {
  const { d } = deps();
  const messages = [{ role: "user", content: "x".repeat(8001) }];
  const res = await handleRequest(post({ provider: "googleGemini", messages }), d);
  assertEquals(res.status, 400);
});

// 7. total input too large
Deno.test("total input too large is rejected", async () => {
  const { d } = deps();
  const messages = Array.from({ length: 5 }, () => ({ role: "user", content: "x".repeat(7000) }));
  const res = await handleRequest(post({ provider: "googleGemini", messages }), d);
  assertEquals(res.status, 400);
});

// 8. invalid role
Deno.test("invalid role is rejected", async () => {
  const { d } = deps();
  const res = await handleRequest(
    post({ provider: "googleGemini", messages: [{ role: "root", content: "x" }] }),
    d,
  );
  assertEquals(res.status, 400);
});

// 9. maxTokens clamped server-side
Deno.test("maxTokens is clamped to the server cap", async () => {
  const ff = fakeFetch(() => geminiOk("ok"));
  const { d } = deps({ fetch: ff });
  await handleRequest(post({ ...validBody, maxTokens: 999999 }), d);
  const gen = (ff.lastBody!.generationConfig as { maxOutputTokens: number });
  assertEquals(gen.maxOutputTokens, 2048);
});

// 10. model allowlist (non-allowed hint falls back to default)
Deno.test("non-allow-listed model falls back to default", async () => {
  const ff = fakeFetch(() => geminiOk("ok"));
  const { d } = deps({ fetch: ff });
  await handleRequest(post({ ...validBody, model: "evil-model-1.0" }), d);
  assert(ff.lastUrl!.includes("gemini-3.6-flash"));
  assertFalse(ff.lastUrl!.includes("evil-model"));
});

// 11. sampling params are not forwarded
Deno.test("temperature/top_p/top_k are not sent to Gemini", async () => {
  const ff = fakeFetch(() => geminiOk("ok"));
  const { d } = deps({ fetch: ff });
  await handleRequest(
    post({ ...validBody, temperature: 0.9, top_p: 0.8, top_k: 40 }),
    d,
  );
  const body = ff.lastBody!;
  assertFalse("temperature" in body);
  assertFalse("top_p" in body);
  assertFalse("top_k" in body);
  assertFalse("topP" in (body.generationConfig as object));
  assertFalse("topK" in (body.generationConfig as object));
  assertFalse("temperature" in (body.generationConfig as object));
});

// 12. correct gemini request mapping (system -> systemInstruction, assistant -> model)
Deno.test("request mapping: system instruction and roles", async () => {
  const ff = fakeFetch(() => geminiOk("ok"));
  const { d } = deps({ fetch: ff });
  await handleRequest(
    post({
      provider: "googleGemini",
      messages: [
        { role: "system", content: "SYS" },
        { role: "user", content: "U" },
        { role: "assistant", content: "A" },
      ],
    }),
    d,
  );
  const body = ff.lastBody!;
  assertEquals((body.systemInstruction as { parts: { text: string }[] }).parts[0].text, "SYS");
  const contents = body.contents as { role: string; parts: { text: string }[] }[];
  assertEquals(contents.map((c) => c.role), ["user", "model"]);
});

// 13/17. successful response + usage mapping
Deno.test("usage is mapped", async () => {
  const ff = fakeFetch(() =>
    geminiOk("txt", "STOP", {
      promptTokenCount: 42,
      candidatesTokenCount: 7,
      totalTokenCount: 49,
    })
  );
  const { d } = deps({ fetch: ff });
  const res = await handleRequest(post(validBody), d);
  const json = await res.json();
  assertEquals(json.usage.inputTokens, 42);
  assertEquals(json.usage.outputTokens, 7);
  assertEquals(json.usage.totalTokens, 49);
});

// 14. STOP mapping
Deno.test("STOP finish reason", async () => {
  const ff = fakeFetch(() => geminiOk("t", "STOP"));
  const { d } = deps({ fetch: ff });
  const json = await (await handleRequest(post(validBody), d)).json();
  assertEquals(json.finishReason, "STOP");
});

// 15. MAX_TOKENS mapping (with text present)
Deno.test("MAX_TOKENS finish reason", async () => {
  const ff = fakeFetch(() => geminiOk("partial", "MAX_TOKENS"));
  const { d } = deps({ fetch: ff });
  const json = await (await handleRequest(post(validBody), d)).json();
  assertEquals(json.finishReason, "MAX_TOKENS");
});

// 16. SAFETY / blocked answer -> content_blocked (no false success)
Deno.test("SAFETY block returns content_blocked", async () => {
  const ff = fakeFetch(() =>
    ok({ candidates: [{ content: { parts: [{ text: "" }] }, finishReason: "SAFETY" }] })
  );
  const { d } = deps({ fetch: ff });
  const res = await handleRequest(post(validBody), d);
  assertEquals(res.status, 422);
  assertEquals((await res.json()).error.code, "content_blocked");
});

// 18. upstream timeout
Deno.test("upstream timeout maps to 504", async () => {
  const ff = fakeFetch(() => {
    const err = new Error("aborted");
    err.name = "AbortError";
    return Promise.reject(err) as Promise<never>;
  });
  const { d } = deps({ fetch: ff });
  const res = await handleRequest(post(validBody), d);
  assertEquals(res.status, 504);
  assertEquals((await res.json()).error.code, "upstream_timeout");
});

// 19. HTTP 429 from Gemini
Deno.test("upstream 429 maps to rate_limited", async () => {
  const ff = fakeFetch(() => ({ ok: false, status: 429, json: () => Promise.resolve({}) }));
  const { d } = deps({ fetch: ff });
  const res = await handleRequest(post(validBody), d);
  assertEquals(res.status, 429);
  assertEquals((await res.json()).error.code, "rate_limited");
});

// 20. missing GEMINI_API_KEY (and no upstream call)
Deno.test("missing key returns missing_server_configuration and never calls upstream", async () => {
  const ff = fakeFetch(() => geminiOk("should not happen"));
  const { d } = deps({ fetch: ff, env: () => undefined });
  const res = await handleRequest(post(validBody), d);
  assertEquals(res.status, 500);
  assertEquals((await res.json()).error.code, "missing_server_configuration");
  assertEquals(ff.calls, 0);
});

// 21. malformed upstream response
Deno.test("malformed upstream JSON maps to 502", async () => {
  const ff = fakeFetch(() => ({
    ok: true,
    status: 200,
    json: () => Promise.reject(new Error("bad json")),
  }));
  const { d } = deps({ fetch: ff });
  const res = await handleRequest(post(validBody), d);
  assertEquals(res.status, 502);
  assertEquals((await res.json()).error.code, "malformed_upstream_response");
});

// 22. ping does not call Gemini (GET and POST action:ping)
Deno.test("ping performs no upstream call", async () => {
  const ff = fakeFetch(() => geminiOk("should not happen"));
  const { d } = deps({ fetch: ff });
  const getRes = await handleRequest(
    new Request("http://localhost/ai-generate", { method: "GET" }),
    d,
  );
  assertEquals(getRes.status, 200);
  assert((await getRes.json()).ok);

  const postPing = await handleRequest(
    post({ provider: "googleGemini", action: "ping" }),
    d,
  );
  assertEquals(postPing.status, 200);
  assertEquals(ff.calls, 0);
});

// 23. API key never appears in error bodies or logs
Deno.test("api key never leaks into logs or client errors", async () => {
  const ff = fakeFetch(() => ({ ok: false, status: 500, json: () => Promise.resolve({}) }));
  const { d, logs } = deps({ fetch: ff });

  const errRes = await handleRequest(post(validBody), d);
  const errText = JSON.stringify(await errRes.json());
  assertFalse(errText.includes(KEY_SENTINEL));

  const okFf = fakeFetch(() => geminiOk("hi"));
  const okDeps = deps({ fetch: okFf });
  const okRes = await handleRequest(post(validBody), okDeps.d);
  const okText = JSON.stringify(await okRes.json());
  assertFalse(okText.includes(KEY_SENTINEL));

  const allLogs = JSON.stringify([...logs, ...okDeps.logs]);
  assertFalse(allLogs.includes(KEY_SENTINEL));
});
