# symphony

The current host orchestrates the full pipeline:

```text
clarify -> plan -> build -> reconcile -> review -> triage -> fix -> done
```

The host owns state, gates, artifacts, and commits but does not edit task code.
Tracked native agents implement and design-review; read-only Codex agents plan and
review correctness/security.

## Configuration and roles

Read `.agent-workflow-kit/config.conf`, active profiles, project rules, and
`docs/ai/agents/cli.md`.

- Planner: `PLANNER_MODEL`.
- Builder/fixer: native `build` agent using `BUILDER_MODEL`.
- Correctness/security: Codex using `CORRECTNESS_MODEL` and `SECURITY_MODEL`.
- Design: native `review-design` agent using `DESIGN_MODEL`.
- Base branch/ref: resolved `BASE_REF`.
- Verification: `CHECK_COMMAND`.

`auto` model values inherit the host/account default. Resolve effort through
`DEFAULT_EFFORT`; workflow `max` maps through host capability config.

## Invariants

1. Ask unresolved material questions in one host-native batch.
2. Only the build agent edits task code. The host may write plans, reviews, and the
   run-state artifact.
3. Reviewers return text and stay read-only.
4. Keep one resumable run file and update it after every phase/round.
5. Commit only on the isolated task branch as part of this explicitly invoked
   workflow. Never push or apply to the resolved base checkout without a separate
   request.
6. Review frozen commits, not a moving dirty tree.
7. Stop only at `done`, a user stop, or a documented escape hatch requiring user
   direction.

## Workspace

If already on an isolated task branch/worktree, use it. Otherwise create a
worktree per `docs/ai/recipes/git-worktree.md`; invoking `symphony` authorizes that
task worktree and its task-branch commits, not changes to the base checkout.

Resolve `BASE_REF=auto` from `origin/HEAD`, falling back to the current base
checkout branch. Record the resolved ref in the run file and use it everywhere.

## Run file

Use `docs/ai/runs/YYYY-MM-DD-short-task.symphony.md` per
`docs/ai/runs/README.md`. Resume an existing task file instead of reopening closed
gates.

## Phases

### 1. Clarify

Inspect the task/code and apply the clarification skill. Ask unresolved red flags
in one batch and record settled decisions.

### 2. Plan

Run `docs/ai/commands/codex-plan.md`. Present the plan path, summary, assumptions,
and gate. User changes return through the planner.

### 3. Build

Launch the native `build` agent against the approved plan. It runs applicable
tests and `CHECK_COMMAND`, returns a summary, and does not commit. The host
reconciles result vs plan, sends technical deviations back for fixes, and asks the
user about semantic scope changes. Commit a clean phase with run state.

### 4. Review

Freeze the commit. Round 1 uses the resolved `BASE_REF...HEAD`; later rounds use
the delta from the last reviewed commit. Run `review-full`, deduplicate against the
existing findings registry, and append one round to the same review artifact.

### 5. Triage

Record findings with stable IDs/status. Present open findings compactly by
severity. The user chooses `accepted`, `rejected`, or `wontfix`; do not hide lower
severities.

### 6. Fix

Send accepted findings to the `build` agent, run `CHECK_COMMAND`, reconcile, and
commit with run state. Mark fixes and return to review on the new delta.

### 7. Done

All are required:

- no open/accepted/regressed Critical or Required findings;
- configured verification passes;
- plan reconciliation is clean;
- the user resolved remaining lower-severity findings.

Mark the run done, commit final state, and return artifact paths, branch/ref, and
summary. Push/PR/apply remain separate user-authorized actions.

## Escape hatches

Ask the user when repeated build/check failures do not improve, verification is
blocked by pre-existing infrastructure, the plan is materially wrong, scope grows,
review rounds stall, or a required reviewer/model is unavailable.
