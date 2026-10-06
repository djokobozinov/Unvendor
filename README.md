# Unvendor

**Leave your Backend-as-a-Service without losing your users, data or access rules.**

Unvendor is an open source CLI that moves a Supabase project to:

- PostgreSQL
- Auth.js or Keycloak for auth
- any S3-compatible store (MinIO, Garage, ...) for files

> Early development, nothing works yet. See the [roadmap](#roadmap).

## Why

Getting into Supabase is easy, getting out is not:

- RLS policies call `auth.uid()`, `auth.jwt()` and `auth.role()`, which only exist in Supabase.
- Users live in `auth.users`, and your tables reference their IDs.
- Storage access rules are database policies. The object store knows nothing about them.

Right now leaving means a dump, some one-off scripts and rewriting access control by hand. Unvendor turns that into something you can run and check.

## What it does

1. **Inventory:** scans the project and lists what has to move.
2. **Auth:** moves users, identities and bcrypt hashes and keeps the user IDs, so nobody has to reset a password.
3. **RLS:** rewrites Supabase-specific policies into plain SQL using a small shim schema. Whatever it can't convert goes into the report.
4. **Storage:** copies buckets and objects and translates the access rules.
5. **Verify:** compares source and target (row counts, logins, RLS checks that should be denied).

## How it behaves

- It never writes to your Supabase project.
- You can run it against a copy as many times as you want before the real cutover.
- Every change it makes ends up in the report.
- Sources are adapters, so Firebase or Appwrite can be added later.

## Roadmap

- [ ] M1: Inventory CLI
- [ ] M2: Auth migration (Auth.js, Keycloak)
- [ ] M3: RLS translation
- [ ] M4: Storage migration
- [ ] M5: Verification, docs, packaging

## Usage

Not implemented yet. Roughly the plan:

```bash
npx unvendor inventory --source "$SUPABASE_DB_URL"
npx unvendor migrate auth --target keycloak
npx unvendor verify
```

## Contributing

If you've moved off Supabase, or tried and gave up, open an issue and describe what broke.

## License

Apache-2.0. See `LICENSE`.
