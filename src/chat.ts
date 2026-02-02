import { z } from "zod";

export interface AiBinding {
  run: (model: string, input: Record<string, unknown>) => Promise<unknown>;
}

export interface Env {
  DB: D1Database;
  RPSLIMIT: string;
  AI: AiBinding;
}

const ChatPayloadSchema = z.object({
  message: z.string().trim().min(1).max(500)
});

export async function handleChatMessage(
  request: Request,
  env: Env
): Promise<Response> {
  if (request.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
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

  await env.DB.prepare(
    "INSERT INTO chat_messages (message, created_at) VALUES (?1, datetime('now'))"
  )
    .bind(message)
    .run();

  return new Response(
    JSON.stringify({ status: "ok", stored: true, message }),
    {
      status: 200,
      headers: { "Content-Type": "application/json" }
    }
  );
}
