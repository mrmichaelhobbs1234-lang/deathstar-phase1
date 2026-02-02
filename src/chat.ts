import { z } from "zod";
import { enforceRateLimit } from "./guards";

export interface AiBinding {
  run: (model: string, input: Record<string, unknown>) => Promise<unknown>;
}

export interface Env {
  DB: D1Database;
  RPSLIMIT: string;
  AI: AiBinding;
  SOVEREIGN_KEY: string;
}

const ChatPayloadSchema = z.object({
  message: z.string().trim().min(1).max(500)
});

function validateSovereignAuth(request: Request, env: Env): Response | null {
  if (!env.SOVEREIGN_KEY) {
    return new Response("Misconfigured", { status: 500 });
  }

  const key = request.headers.get("x-sovereign-key");
  if (!key) {
    return new Response("Unauthorized", { status: 401 });
  }

  if (key !== env.SOVEREIGN_KEY) {
    return new Response("Forbidden", { status: 403 });
  }

  return null;
}

export async function handleChatMessage(
  request: Request,
  env: Env
): Promise<Response> {
  if (request.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const authError = validateSovereignAuth(request, env);
  if (authError) {
    return authError;
  }

  const rateLimit = await enforceRateLimit(env);
  if (rateLimit) {
    return rateLimit;
  }

  let payload: unknown;
  try {
    payload = await request.json();
  } catch (error) {
    return new Response("Invalid JSON", { status: 400 });
  }

  const parsed = ChatPayloadSchema.safeParse(payload);
  if (!parsed.success) {
    return new Response("Message required", { status: 400 });
  }
  const { message } = parsed.data;

  await env.DB
    .prepare(
      "INSERT INTO chat_messages (ts, role, message) VALUES (?1, ?2, ?3)"
    )
    .bind(Date.now(), "user", message)
    .run();

  return new Response(
    JSON.stringify({ status: "ok", stored: true, message }),
    {
      status: 200,
      headers: { "Content-Type": "application/json" }
    }
  );
}
