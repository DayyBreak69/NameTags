// DayBreak shared nametag presence registry
// Cloudflare Worker + KV
//
// Create a KV namespace and bind it to this Worker as:
//   variable: PRESENCE
//
// KV entries use:
//   p:<RobloxUserId>
//
// Each heartbeat refreshes the entry for 20 seconds.
// GET /players returns everyone whose entry is still alive.

const TTL_SECONDS = 20;

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Content-Type": "application/json",
  };
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: corsHeaders(),
  });
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders() });
    }

    const url = new URL(request.url);

    if (url.pathname === "/heartbeat" && request.method === "POST") {
      let data;

      try {
        data = await request.json();
      } catch {
        return json({ error: "Invalid JSON" }, 400);
      }

      const userId = Number(data.userId);

      if (!Number.isInteger(userId) || userId <= 0) {
        return json({ error: "Invalid userId" }, 400);
      }

      const record = {
        userId,
        username: String(data.username || ""),
        displayName: String(data.displayName || ""),
        updatedAt: Date.now(),
      };

      await env.PRESENCE.put(
        `p:${userId}`,
        JSON.stringify(record),
        { expirationTtl: TTL_SECONDS }
      );

      return json({ ok: true });
    }

    if (url.pathname === "/players" && request.method === "GET") {
      const listed = await env.PRESENCE.list({ prefix: "p:" });
      const players = [];

      for (const key of listed.keys) {
        const raw = await env.PRESENCE.get(key.name);

        if (!raw) {
          continue;
        }

        try {
          const record = JSON.parse(raw);
          players.push({
            userId: record.userId,
            username: record.username,
            displayName: record.displayName,
          });
        } catch {
          // Ignore malformed records.
        }
      }

      return json({
        players,
        ttl: TTL_SECONDS,
      });
    }

    return json({
      ok: true,
      service: "DayBreak Nametag Registry",
      endpoints: ["/heartbeat", "/players"],
    });
  },
};
