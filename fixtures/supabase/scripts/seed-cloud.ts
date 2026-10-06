// Seeds a hosted Supabase project: users, rows, storage files.
// Run: SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... npx tsx scripts/seed-cloud.ts
import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL!;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY!;
const sb = createClient(url, key, { auth: { persistSession: false } });

const ALICE = "11111111-1111-1111-1111-111111111111";
const BOB = "22222222-2222-2222-2222-222222222222";
const ORG = "33333333-3333-3333-3333-333333333333";

async function must<T>(p: PromiseLike<{ data: T; error: unknown }>, what: string) {
  const { data, error } = await p;
  if (error) throw new Error(`${what}: ${JSON.stringify(error)}`);
  return data;
}

async function user(id: string, email: string, app_metadata = {}) {
  const { error } = await sb.auth.admin.createUser({
    id, email, password: "password123", email_confirm: true, app_metadata,
  });
  if (error && !/already/i.test(error.message)) throw error;
}

await user(ALICE, "alice@example.com", { role: "admin" });
await user(BOB, "bob@example.com");

await must(sb.from("profiles").upsert([
  { id: ALICE, username: "alice" },
  { id: BOB, username: "bob" },
]), "profiles");

await must(sb.from("notes").insert([
  { owner_id: ALICE, body: "alice private", is_public: false },
  { owner_id: ALICE, body: "alice public", is_public: true },
  { owner_id: BOB, body: "bob private", is_public: false },
]), "notes");

await must(sb.from("orgs").upsert({ id: ORG, name: "Acme" }), "orgs");
await must(sb.from("org_members").upsert({ org_id: ORG, user_id: ALICE, role: "owner" }), "org_members");

const file = (s: string) => new Blob([s], { type: "text/plain" });
await must(sb.storage.from("avatars").upload(`${ALICE}/avatar.txt`, file("alice avatar"), { upsert: true }), "avatar");
await must(sb.storage.from("documents").upload(`${BOB}/contract.txt`, file("bob doc"), { upsert: true }), "document");

console.log("Seeded.");
