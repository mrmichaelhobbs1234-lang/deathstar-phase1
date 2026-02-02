import type { Env } from "./chat";

export interface LedgerAppendInput {
  ledgerid: string;
  blockid: string;
  nonce: number;
}

export async function appendLedgerEntry(
  env: Env,
  entry: LedgerAppendInput
): Promise<Response | null> {
  const row = await env.DB
    .prepare("SELECT MAX(nonce) as maxNonce FROM ledger WHERE ledgerid = ?1")
    .bind(entry.ledgerid)
    .first<{ maxNonce: number | null }>();

  const maxNonce = row?.maxNonce ?? 0;
  if (entry.nonce <= maxNonce) {
    return new Response("Nonce replay", { status: 409 });
  }

  await env.DB
    .prepare(
      "INSERT INTO ledger (ledgerid, blockid, nonce) VALUES (?1, ?2, ?3)"
    )
    .bind(entry.ledgerid, entry.blockid, entry.nonce)
    .run();

  return null;
}
