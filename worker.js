export default {
  async fetch(request, env, ctx) {
    return new Response(
      JSON.stringify({
        status: "PHASE_1_ALIVE",
        timestamp: Date.now()
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" }
      }
    );
  }
};
