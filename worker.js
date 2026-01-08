export default {
  async fetch(request, env, ctx) {
    const key = request.headers.get("x-deathstar-key");

    if (!key || key !== env.DEATHSTAR_INGEST_KEY) {
      return new Response(
        JSON.stringify({
          status: "BLOCKED",
          reason: "INVALID_KEY"
        }),
        { status: 403 }
      );
    }

    return new Response(
      JSON.stringify({
        status: "PHASE_1_OK",
        message: "Live traffic authenticated",
        timestamp: Date.now()
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" }
      }
    );
  }
};
