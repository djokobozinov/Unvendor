# Unvendor

**An exit toolkit for Backend-as-a-Service platforms, starting with Supabase.**

Unvendor is an open source toolkit for converting a Backend-as-a-Service deployment into standard, self-hostable components: plain PostgreSQL, OIDC-based auth and S3-compatible storage. The goal is to do this without a full rewrite of the app. Supabase is the first source platform and the reference implementation; others are planned through a source adapter interface.

> **Status: early development.** No component is usable yet. See [What it does](#what-it-does) and the [roadmap](#roadmap).

## Why

Backend-as-a-Service platforms (Supabase, Firebase, Appwrite, Nhost, PocketBase) bundle database, auth, storage and functions behind platform-specific APIs. Apps built on them become hard to self-host, migrate or audit, even when parts of the platform are open source.

On Supabase, for example:

- RLS policies call `auth.uid()`, `auth.jwt()` and `auth.role()`, which only exist in Supabase.
- Users live in `auth.users`, and application tables reference their IDs.
- Storage access rules are database policies. The object store knows nothing about them.

Today, leaving means a dump, one-off scripts and rewriting access control by hand. Self-hosting the platform itself changes where it runs, not what the app depends on: you still operate its services and stay on its schemas.

Unvendor is for teams that need to run their backend on infrastructure they control: small teams, NGOs, public bodies, and anyone who needs data sovereignty, GDPR-compliant self-hosting, or protection against pricing or platform changes.

## What it does

Each component moves one part of the platform onto a standard replacement that can be swapped independently.

| # | Component | Target | Status |
|---|-----------|--------|--------|
| 1 | Schema, data and RLS exporter | PostgreSQL | Planned |
| 2 | Auth migration | OIDC providers (Keycloak, Authentik, Zitadel) | Planned |
| 3 | Storage export | S3-compatible storage (MinIO, Garage, Ceph) | Planned |
| 4 | Client compatibility shim | Existing app clients | Planned |
| 5 | Source adapter interface | Future sources (Firebase, Appwrite, ...) | Planned |

1. **Schema, data and RLS exporter.** Exports schema and data to plain PostgreSQL. RLS policies that use Supabase-specific functions are rewritten against a small shim schema; anything that can't be converted is listed in the report.
2. **Auth migration.** Moves users and identities to an OIDC provider, keeping user IDs and existing password hashes where the provider supports it, so users don't have to reset their passwords.
3. **Storage export.** Copies buckets and objects to any S3-compatible backend and translates the access rules.
4. **Client compatibility shim.** Lets an existing app keep running against the new components during migration, so client code can be ported step by step instead of all at once.
5. **Source adapter interface.** Separates platform-specific reading from the rest of the pipeline, so other platforms can be added as sources.

### Design rules

These apply to every component as it is built:

- Never write to the source project.
- Can be run against a copy any number of times before the real cutover.
- Every change made to the target is recorded in a report.
- Anything that can't be converted automatically goes into the report instead of being skipped.
- Every RLS rewrite has a negative test proving that forbidden rows stay hidden.

### What exists today

- A Supabase test fixture in [`fixtures/supabase/`](fixtures/supabase/): tables with RLS policies that call `auth.uid()`, `auth.jwt()` and `auth.role()`, storage buckets with per-user folder policies, and a seed script. It is the source project used to develop and test the components above.
- The project website in [`site/`](site/).

## Quick start

There is no runnable CLI yet. To set up the test fixture against a hosted Supabase project, see [`fixtures/supabase/README.md`](fixtures/supabase/README.md).

## Roadmap

- [ ] M1: Schema, data and RLS exporter → PostgreSQL
- [ ] M2: Auth migration → OIDC providers (Keycloak, Authentik, Zitadel)
- [ ] M3: Storage export → S3-compatible storage (MinIO, Garage, Ceph)
- [ ] M4: Client compatibility shim
- [ ] M5: Source adapter interface (Firebase, Appwrite and others later)

## Contributing

If you've moved off a Backend-as-a-Service platform, or tried and gave up, open an issue and describe what broke. Real migration cases shape the roadmap and the test suite.

The project is written in TypeScript. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

Apache-2.0. See [LICENSE](LICENSE).

Unvendor is not affiliated with or endorsed by Supabase or any other platform mentioned here.

## Mirrors

- GitHub: [github.com/djokobozinov/unvendor](https://github.com/djokobozinov/unvendor)
- Codeberg: [codeberg.org/gjokob/unvendor](https://codeberg.org/gjokob/unvendor)
