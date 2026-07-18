# Review Security

Run a dedicated security pass only when the user requests it or the changed diff
crosses a security boundary.

## Risk signals

- identity, authentication, authorization, session, or access control;
- sensitive data, secrets, money/value, regulated behavior, or destructive action;
- user/external input, files/media, URLs, rendering, parsers, or code execution;
- storage, network, external services, permissions, configuration, or logging;
- dependencies, supply chain, cryptography, signatures, or randomness.

## What to check

- Authority and trust boundaries: who can invoke the action and which data is
  trusted at each step.
- Validation/canonicalization before security decisions or dangerous sinks.
- Secret and sensitive-data exposure in code, storage, transport, logs, errors,
  and artifacts.
- Bypass, confused-deputy, replay, race, duplicate-action, and stale-state paths.
- Safe defaults and failure behavior for config, dependencies, and feature flags.
- Applicable scanners/queries from active profiles. A discovery hit is not a
  finding until the code path proves risk.

## Severity

- `Critical`: exploitable vulnerability, secret leak, or data/value loss.
- `Required`: high-risk pattern that must be fixed before integration.
- `Nit`: small hardening with low cost and a concrete risk reduction.
- `Optional`: defense in depth.
- `FYI`: relevant risk context without a required fix.

## Format

```markdown
Critical: N | Required: N | Nit: N | Optional: N | FYI: N

### [severity]
**File:** `path`
**Risk:** [abuse/failure case]
**Evidence:** [diff/code path]
**Fix:** [concrete secure fix]
```

If clean: `No security problems found`.
