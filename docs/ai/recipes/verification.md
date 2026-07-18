# Verification Pass

Use this extra pass when requested or when a change is broad, public,
irreversible, security-sensitive, concurrent, or crosses a trust boundary.

## Process

1. Read config, active profiles, and applicable project rules.
2. Resolve the requested diff/range; otherwise inspect unstaged and staged changes.
3. Compare the task scope with changed files and identify stray or missing work.
4. Trace changed public contracts and boundaries to their consumers.
5. Run only scanners/checks supplied by active profiles and project tooling.
6. Run the narrow behavior checks for the task.
7. Run `CHECK_COMMAND` unless configured as `none`.
8. Record any manifest/config/dependency implications or why none apply.

## Result checklist

- The diff matches the requested scope.
- No conflict markers, debug residue, credentials, or unrelated generated files.
- Applicable contracts, boundaries, failures, and recovery paths were checked.
- Active-profile checks were run and interpreted in context.
- `CHECK_COMMAND` passes, or the exact external/pre-existing blocker is recorded.
