# Contributing to Unvendor

Thanks for your interest. Unvendor is in early development and nothing works yet, so the most useful contributions right now are real-world migration stories and test cases.

## Share what broke

If you've moved off Supabase, or tried and gave up, open an issue and describe:

- What you were migrating (auth, RLS policies, storage, functions, ...).
- Where you were moving to (plain PostgreSQL, Auth.js, Keycloak, MinIO, Garage, something else).
- What broke, what you had to do by hand, and any scripts you wrote.

Links to public discussions, blog posts or repos are welcome. These shape the roadmap and the test suite.

## Test cases

A migration tool is only as good as the cases it is checked against. Useful contributions:

- RLS policies that use `auth.uid()`, `auth.jwt()` or `auth.role()` in ways you suspect are hard to translate.
- Auth setups with OAuth identities, unconfirmed emails or MFA factors.
- Storage bucket policies that depend on database state.

Strip anything private before sharing. A minimal SQL snippet that reproduces the shape of the problem is enough.

## Code

The project is TypeScript, distributed via `npx`, licensed under Apache-2.0. Before starting a larger change, open an issue so we can agree on the approach. Keep pull requests focused on one thing.

Rules the tool must follow, and that every change must respect:

- Never write to the source Supabase project.
- Every change made to the target must be recorded in the report.
- Anything that cannot be converted automatically goes into the report instead of being silently skipped.
- Every RLS rewrite needs a negative test proving that forbidden rows stay hidden.

## Roadmap

Work is organised by milestone. See the roadmap in [README.md](README.md) and the corresponding issues for M1 to M5.

## License

By contributing you agree that your contributions are licensed under the Apache-2.0 license. See [LICENSE](LICENSE).
