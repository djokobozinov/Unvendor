# Supabase test fixture

A small hosted Supabase project used as the source when developing and testing `unvendor inventory`.

The migration in `supabase/migrations/` creates four tables (`profiles`, `notes`, `orgs`, `org_members`) with RLS policies that call `auth.uid()`, `auth.jwt()` and `auth.role()`, including one inside a subquery. It also creates two storage buckets, `avatars` (public) and `documents` (private), with policies that limit access to a folder named after the user's ID. The seed script adds two users, alice (admin, via `app_metadata.role`) and bob, plus some rows and one file per bucket.

## Setup

Create a free project on supabase.com in the Frankfurt (eu-central-1) region. Then, from `fixtures/supabase`:

```bash
npx supabase login
npx supabase link --project-ref <ref>
npx supabase db push
```

Copy `.env.example` at the repo root to `.env` and fill in the project URL, the service role key and the database URL from the project dashboard. Then, from the repo root:

```bash
npm run fixture:seed
```

## Test users

- alice@example.com, password `password123`
- bob@example.com, password `password123`

## Expected behaviour

Signed in as alice, `notes` returns all three notes, including "bob private", because she is an admin.

Signed in as bob, `notes` returns "bob private" and "alice public", but not "alice private".

## Re-running the seed

The seed can be run again safely. Users, profiles, orgs, memberships and files are created or upserted. The exception is `notes`: each run inserts the three notes again, so they duplicate.

## Keys

The service role key bypasses RLS and has full access to the project. Keep it in `.env`, which is gitignored, and never commit it.
