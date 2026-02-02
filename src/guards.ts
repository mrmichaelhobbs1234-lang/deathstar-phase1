import type { Env } from "./chat";

const SECOND_MS = 1000;
const RATE_LIMIT_ERROR = new Response("Rate limited", { status: 429 });
const MISCONFIGURED_ERROR = new Response("Misconfigured", { status: 500 });

export async function enforceRateLimit(env: Env): Promise<Response | null> {
  const limit = Number.parseInt(env.RPSLIMIT, 10);
  if (!Number.isFinite(limit) || limit <= 0) {
    return MISCONFIGURED_ERROR;
  }

  const ts = Math.floor(Date.now() / SECOND_MS);
  await env.DB.prepare(
    "INSERT INTO ratelimiter (ts, count) VALUES (?1, 1) ON CONFLICT(ts) DO UPDATE SET count = count + 1"
  )
    .bind(ts)
    .run();

  const cur = await env.DB
    .prepare("SELECT count FROM ratelimiter WHERE ts = ?1")
    .bind(ts)
    .first<{ count: number }>();

  if ((cur?.count ?? 0) > limit) {
    return RATE_LIMIT_ERROR;
  }

  return null;
}

export function enforceNonceWindow(nonce: number): Response | null {
  const windowMs = 5 * 60 * 1000;
  const now = Date.now();

  if (Math.abs(now - nonce) > windowMs) {
    return new Response("Nonce outside window", { status: 409 });
  }

  return null;
}

export async function enforceAiQuota(
  env: Env,
  limit = 50
): Promise<Response | null> {
  const windowMs = 60 * 60 * 1000;
  const cutoff = Date.now() - windowMs;

  const q = await env.DB
    .prepare("SELECT COUNT(*) as calls FROM aiusage WHERE ts > ?1")
    .bind(cutoff)
    .first<{ calls: number }>();

  if ((q?.calls ?? 0) >= limit) {
    return Response.json({ error: "AI quota exceeded" }, { status: 429 });
  }

  await env.DB.prepare("INSERT INTO aiusage (ts) VALUES (?1)")
    .bind(Date.now())
    .run();

  return null;
}
