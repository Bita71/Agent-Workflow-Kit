# deps-audit

A read-only audit of runtime dependency risk. Read `DEPENDENCY_ECOSYSTEM` from
`.agent-workflow-kit/config.conf`; when it is `auto`, detect the ecosystem from
the repository's manifests and lockfiles. If detection is ambiguous, ask instead
of assuming a package manager.

## Scope

- Inspect the selected ecosystem's manifest, lockfile, installed dependency
  graph, and authoritative advisory source.
- Do not change dependencies, generated files, or code without an explicit
  request.
- Prefer runtime/production dependencies. Include build, development, or test
  tooling only when the user requests it or evidence shows a production impact.
- Show critical/high findings; include lower severities only with a realistic
  impact on this repository's runtime or supply chain.
- Separate deprecated or abandoned packages from confirmed vulnerabilities.
- If the ecosystem does not distinguish runtime and development dependencies,
  state the limitation and classify findings from actual use where possible.

## Commands

Use the repository's own package/dependency manager and its official audit,
explain, and registry-inspection commands. Do not substitute npm, PyPI, Cargo,
Maven, NuGet, Go, or another ecosystem merely because it is familiar.

Before reporting a target version, verify it against the authoritative registry
or project source. If current network access is unavailable, report the version
as unverified rather than guessing.

## Analysis

For each important finding, provide:

- dependency and current resolved version;
- direct or transitive relationship;
- fixed/target version when verified;
- severity and practical exploit or failure path;
- whether the affected code is reachable in this repository's runtime;
- update risk, including breaking-version boundaries.

## Result

```markdown
## Runtime Security Shortlist

- `<dependency>` `<current>` -> `<target>` — `<severity>`, `<why it matters>`.

## Not included

- `<dependency/tool>` — `<why it is not a runtime blocker>`.

## Order

1. `<most important dependency>`
2. `<next dependency>`

## Checks after an update

- `<check>`
- `<focused runtime smoke test>`
```
