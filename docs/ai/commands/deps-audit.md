# deps-audit

A periodic breakdown of dependency vulnerabilities. By default — runtime risk
only.

## Scope

- Read `package.json` and the lockfile.
- Do not change dependencies, the lockfile, or code without an explicit request.
- Include in the main result only runtime `dependencies`: direct packages and
  transitive vulnerabilities that are fixed by updating a direct runtime
  dependency.
- Show `critical`/`high`; `moderate` only if there is a realistic runtime impact.
- Do not include `devDependencies` and tooling (bundlers, component/e2e tooling,
  linters, test runners) unless the user asked for a dev/build audit.
- Break out deprecated packages separately as a maintenance/supply-chain risk.

## Commands

Use your package manager's audit and inspection commands, for example:

```bash
<pm> audit --recursive --environment production --severity high
<pm> audit --recursive --environment production --severity moderate
<pm> audit --recursive --environment production --severity moderate --json
<pm> why <package>
npm view <package> version
```

## Analysis

- For each important finding, give the package, the current version, the target
  version, the severity, the gist of the risk, and its applicability to your
  runtime target.
- If the advisory applies to a Node-only adapter, SSR, a dev server, or a
  build-time path — mark that and do not raise the priority without evidence.
- Assess the update risk by the bump type: patch/minor/major.

## Result

```markdown
## Runtime Security Shortlist

- `<package>` `<current>` → `<target>` — `<severity>`, `<why update>`.

## Not included

- `<package/tooling>` — `<why it is not runtime, or why not a security blocker>`.

## Order

1. `<most important package>`
2. `<next package>`

## Checks after the update

- `<check>`
- a relevant smoke test of the runtime flow, if the package affects
  routing/network/socket/i18n/forms.
```
