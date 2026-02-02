export interface Env {
  DB: D1Database;
}

interface ChatPayload {
  message?: string;
}

export async function handleChatMessage(
  request: Request,
  env: Env
): Promise<Response> {
  if (request.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  let payload: ChatPayload;
  try {
    payload = await request.json();
  } catch (error) {
    return new Response("Invalid JSON", { status: 400 });
  }

  const message = payload.message?.trim();
  if (!message) {
    return new Response("Message required", { status: 400 });
  }

  await env.DB.prepare(
    "INSERT INTO ledger (message, created_at) VALUES (?, datetime('now'))"
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
