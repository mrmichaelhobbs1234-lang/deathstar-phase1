import { handleChatMessage, type Env } from "./chat";

const CHAT_HTML = `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Magic Chat</title>
    <style>
      :root {
        color-scheme: dark;
      }

      * {
        box-sizing: border-box;
      }

      body {
        margin: 0;
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: stretch;
        background: #0f0f1a;
        color: #f8f7ff;
        font-family: "Inter", system-ui, -apple-system, sans-serif;
      }

      .chat-shell {
        width: 100%;
        max-width: 960px;
        display: flex;
        flex-direction: column;
        padding: 32px 24px;
        gap: 24px;
      }

      header {
        display: flex;
        justify-content: space-between;
        align-items: center;
      }

      .title {
        font-size: 28px;
        font-weight: 700;
        color: #a855f7;
      }

      .status {
        font-size: 14px;
        padding: 6px 14px;
        border-radius: 999px;
        background: rgba(245, 158, 11, 0.15);
        color: #f59e0b;
        border: 1px solid rgba(245, 158, 11, 0.4);
      }

      .messages {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 16px;
        padding: 24px;
        border-radius: 24px;
        background: rgba(168, 85, 247, 0.08);
        border: 1px solid rgba(168, 85, 247, 0.3);
        overflow-y: auto;
      }

      .message {
        padding: 16px 18px;
        border-radius: 18px;
        background: rgba(15, 15, 26, 0.7);
        border: 1px solid rgba(168, 85, 247, 0.4);
        color: #f8f7ff;
        display: inline-flex;
        flex-direction: column;
        gap: 6px;
        max-width: 80%;
      }

      .message.self {
        align-self: flex-end;
        background: rgba(245, 158, 11, 0.16);
        border-color: rgba(245, 158, 11, 0.45);
      }

      .message .meta {
        font-size: 12px;
        color: rgba(248, 247, 255, 0.6);
      }

      form {
        display: flex;
        gap: 12px;
        padding: 16px;
        border-radius: 18px;
        background: rgba(15, 15, 26, 0.9);
        border: 1px solid rgba(168, 85, 247, 0.4);
      }

      input[type="text"] {
        flex: 1;
        background: transparent;
        border: none;
        color: #f8f7ff;
        font-size: 16px;
        outline: none;
      }

      button {
        background: linear-gradient(135deg, #a855f7, #f59e0b);
        border: none;
        color: #0f0f1a;
        font-weight: 700;
        padding: 12px 22px;
        border-radius: 14px;
        cursor: pointer;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
      }

      button:hover {
        transform: translateY(-1px);
        box-shadow: 0 12px 30px rgba(168, 85, 247, 0.25);
      }

      @media (max-width: 720px) {
        .chat-shell {
          padding: 24px 16px;
        }

        .message {
          max-width: 100%;
        }

        form {
          flex-direction: column;
        }

        button {
          width: 100%;
        }
      }
    </style>
  </head>
  <body>
    <main class="chat-shell">
      <header>
        <div>
          <div class="title">Magic Chat</div>
          <div class="meta">Connect with the Phoenix Empire command stream.</div>
        </div>
        <div class="status" id="status">Ready</div>
      </header>

      <section class="messages" id="messages" aria-live="polite">
        <article class="message">
          <strong>Magic Chat Bot</strong>
          <span>Welcome to the Phoenix Empire feed. Drop a message to begin.</span>
          <span class="meta">System</span>
        </article>
      </section>

      <form id="chat-form">
        <input
          type="text"
          id="message-input"
          name="message"
          placeholder="Send a message..."
          autocomplete="off"
          required
        />
        <button type="submit">Send</button>
      </form>
    </main>

    <script>
      const form = document.getElementById("chat-form");
      const input = document.getElementById("message-input");
      const messages = document.getElementById("messages");
      const status = document.getElementById("status");

      function appendMessage(content, author = "You") {
        const wrapper = document.createElement("article");
        wrapper.className = "message self";

        const name = document.createElement("strong");
        name.textContent = author;

        const body = document.createElement("span");
        body.textContent = content;

        const meta = document.createElement("span");
        meta.className = "meta";
        meta.textContent = "Just now";

        wrapper.appendChild(name);
        wrapper.appendChild(body);
        wrapper.appendChild(meta);

        messages.appendChild(wrapper);
        messages.scrollTop = messages.scrollHeight;
      }

      async function sendMessage(value) {
        status.textContent = "Sending...";

        try {
          const response = await fetch("/chat/message", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ message: value })
          });

          if (!response.ok) {
            throw new Error("Request failed");
          }

          status.textContent = "Sent";
        } catch (error) {
          console.error(error);
          status.textContent = "Failed";
        }
      }

      form.addEventListener("submit", async (event) => {
        event.preventDefault();
        const value = input.value.trim();

        if (!value) {
          return;
        }

        appendMessage(value);
        input.value = "";
        await sendMessage(value);
      });
    </script>
  </body>
</html>`;

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // Chat UI endpoint
    if (url.pathname === "/chat" && request.method === "GET") {
      return new Response(CHAT_HTML, {
        headers: { "Content-Type": "text/html; charset=utf-8" }
      });
    }

    // Chat message endpoint
    if (url.pathname === "/chat/message" && request.method === "POST") {
      return handleChatMessage(request, env);
    }

    return new Response("Not Found", { status: 404 });
  }
};
