# Review Correctness

Find real behavior defects in the changed scope. Do not review style or broad
architecture unless it directly causes a bug.

## Context and scope

- Read config, active profiles, and applicable project rules.
- Review the requested diff/range and its directly affected paths.
- Use changed code as the source of truth; inspect neighboring code only to prove
  behavior.
- Do not report unrelated pre-existing problems unless the change activates them.

## What to check

- Task conformance and preserved behavior outside the requested change.
- Boundary values, absence/empty input, invalid input, partial failure, and error
  propagation where applicable.
- State transitions, cleanup, concurrency, ordering, retry, cancellation, and
  repeated actions where applicable.
- Trust boundaries and validation of external or lower-authority data.
- Public contract compatibility, consumers, serialization, and migration.
- Important changed behavior without an executable or documented verification.
- Additional language/framework/domain checks from active profiles only.

## Security baseline

Report an obvious security defect when the changed path proves it. Use the
security skill for a dedicated risk-driven pass.

## Severity

- `Critical`: exploitable security issue, data loss, or broken core behavior.
- `Required`: bug, regression, invalid contract, or missing required validation.
- `Nit`: small concrete change that reduces a demonstrated error risk.
- `Optional`: improvement that does not block integration.
- `FYI`: relevant context without a required change.

## Format

```markdown
Critical: N | Required: N | Nit: N | Optional: N | FYI: N

### [severity]
**File:** `path`
**Problem:** [what breaks]
**Evidence:** [line, diff, or code path]
**Fix:** [concrete fix]
```

If clean: `No critical correctness problems found`.
