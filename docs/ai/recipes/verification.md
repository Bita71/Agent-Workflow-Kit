# Verification Pass

A recipe for extra verification after implementation. Use it when the user asks, or
when the change is large or critical: many files, public API, data contracts,
security-sensitive domains (auth, payments, money, PII, access control), user
input, permissions, race conditions, retries, idempotency, or external data.

For a small, pointed change, the normal workflow checks are usually enough.

## Process

1. Identify the changed files:

   ```bash
   git diff --name-only
   git diff --stat
   ```

2. Compare the task's stated scope against the diff: any stray files or unfinished
   changes.
3. Check the applicable rules from `docs/ai/rules/project.md` and
   `docs/ai/rules/coding-rules.md`, but only over the changed files.
4. If a public API, DTO, query/mutation, or cross-module link changed, check its
   consumers and exports.
5. If the changed files include `.ts`, `.tsx`, `.js`, `.jsx`, run a security grep
   over them.
6. Run `<check>` and wait for the result.
7. If a manifest, lockfile, or dependency config changed, run a dependency audit or
   record why one is not needed.

## Security Grep

A grep hit is not a bug. Check the context and add only real risks or useful
warnings to the report.

```bash
rg -n 'dangerouslySetInnerHTML|innerHTML|eval\(|new Function\(|document\.write|javascript:' <changed-files>
rg -n 'apiKey|secretKey|privateKey|password|token' --case-sensitive <changed-files>
rg -n 'localStorage|sessionStorage|postMessage|window\.open|location\.href' <changed-files>
rg -n 'console\.(log|debug)' <changed-files>
```

## Checklist

- [ ] The diff matches the stated scope.
- [ ] No stray files and no leftover debug edits.
- [ ] Applicable project/coding rules are followed.
- [ ] Public API / contracts / exports checked, if changed.
- [ ] The task's edge cases are covered by code, tests, or a manual check.
- [ ] Security grep done, if there are relevant changed files.
- [ ] `<check>` passes.

## Report format

```markdown
## Passed

- [what was checked and passed]

## Failed

- `[file]` — [the problem] — [what needs fixing]

## Warnings

- `[file]` — [a risk or incomplete confidence]

## Not checked

- [what could not be checked and why]
```

If everything is fine: `Verification passed`, and briefly list the key checks.
