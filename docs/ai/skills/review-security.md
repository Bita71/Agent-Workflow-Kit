# Review Security

Look only for real security risks. This is an optional review; it runs on risk signals, not on every diff.

## When it's needed

- auth/authorization/session/access control;
- security-sensitive domains: payments, money, PII, transaction/checkout flows;
- user input, URL, deep links, HTML/markdown, file/media;
- storage/localStorage/sessionStorage/cookies;
- external API, browser APIs, postMessage;
- dependencies, env/config, logging, error-tracker breadcrumbs;
- crypto/signature/encryption/randomness.

## What to check

- Applicable security-sensitive project rules from `docs/ai/rules/project.md` and `docs/ai/rules/coding-rules.md`, if they relate to the changed diff.
- Trust boundaries: where input comes from user/backend/storage/URL and how it's validated.
- XSS/HTML/script injection: `dangerouslySetInnerHTML`, `innerHTML`, `javascript:`, unsafe URL.
- Secrets/PII: tokens, private keys, passwords, personal data in code, storage, or logs.
- Auth/access control: can a check be bypassed, an action invoked without the required state or permissions.
- Money/funds: race condition, double submit, idempotency, stale balance, recipient substitution.
- Dependency/config: new dependencies, env flags, debug modes, insecure defaults.
- Error handling: whether internal details or sensitive data are exposed.

## Quick grep

If there are changed `.ts/.tsx/.js/.jsx`, check the relevant changed files:

```bash
rg -n 'dangerouslySetInnerHTML|innerHTML|eval\(|new Function\(|document\.write|javascript:' <changed-files>
rg -n 'apiKey|secretKey|privateKey|password|token' --case-sensitive <changed-files>
rg -n 'localStorage|sessionStorage|postMessage|window\.open|location\.href' <changed-files>
rg -n 'console\.(log|debug|warn|error)' <changed-files>
```

A grep hit isn't a bug. Check the context.

## Severity

- `Critical`: exploitable vulnerability, data/funds loss, secret leak.
- `Required`: high-risk pattern that should be fixed before merge.
- `Nit`: small hardening with low cost.
- `Optional`: defense-in-depth.
- `FYI`: risk note without a required fix.

## Don't

- Don't do a general code review.
- Don't report theoretical OWASP items unconnected to the diff.
- Don't demand a dependency audit if dependencies didn't change.

## Format

```markdown
Critical: N | Required: N | Nit: N | Optional: N | FYI: N

### [Critical / Required / Nit / Optional / FYI]

**File:** `path`
**Risk:** [vulnerability / abuse case]
**Evidence:** [diff/code path]
**Fix:** [concrete secure fix]
```

If there are no problems: `No security problems found`.
