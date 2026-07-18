# symphony

The full task pipeline under Claude's control: clarify → plan (Codex) → build
(subagent) → reconcile against the plan → parallel review → triage → fix loop →
done. The human is the conductor at the gates. The orchestrator makes no
assumptions, does not write code itself, and does not stop until the task is
done or the human stops it.

Every phase is the same pattern: **produce → verify → fix → repeat**. Only the
performer, the judge, and the exit condition change.

## Roles

- **Orchestrator** (this command, the current session, a strong model): owns
  state and the run file, the gates and questions, the reconciliations, dedup
  and triage, and commits. Does **not** edit code.
- **Codex** (`gpt-5.5`, calls strictly per `docs/ai/agents/cli.md`): the plan
  and correctness/security review.
- **Build subagent** (Agent tool): all code — the implementation and every fix.
- **Design reviewer** (subagent `review-design`, opus).

## Invariants

1. Ask instead of assuming. Red flags from
   `docs/ai/skills/implementation-clarify.md` always go to the human.
2. Questions to the human go in a single batch, grouped (AskUserQuestion), with
   answer options. Never one at a time.
3. Only the build subagent writes code. The orchestrator reads, reconciles, and
   formulates.
4. Do not stop on your own: the end is only "done" (see phase 7) or a human
   stop. An escape hatch is not a silent stop — it is a question to the human.
5. The run file is updated and committed after every phase and every round.
6. CLI calls come only from `docs/ai/agents/cli.md`.
7. Models are strong-only; intelligence is tuned with effort
   (`docs/ai/commands/choose-model.md`). Mechanical steps get low effort, not a
   weaker model. State the model/effort choice in one line before each phase.

## Workspace and commits

- If the session is already on an isolated branch (a remote session, a ready
  worktree), work in it. Otherwise create a worktree per
  `docs/ai/recipes/git-worktree.md` and a task branch; invoking `/symphony` is
  itself the user's request for a worktree.
- Invoking `/symphony` is a mandate to commit **on the task branch**: commit
  after every phase and every fix round (`docs/ai/rules/commit-message.md`; the
  run file goes into the same commit). Do not commit to other branches, do not
  push, and do not apply to main without an explicit request.
- Review always runs against a frozen commit (sha), never against a dirty tree.
- All edits and checks happen in the task tree (path pitfalls are in the
  "Pitfalls" section of the worktree recipe; pass subagents the absolute path of
  the tree).

## Run file (resume)

`docs/ai/runs/YYYY-MM-DD-short-task.symphony.md`, format per
`docs/ai/runs/README.md`. Before starting, check whether a run file for this
task already exists: if so, read the state and continue from the recorded phase.
Do not start over and do not repeat closed gates.

## Phases

### 1. Clarify (gate)

1. Study the task and the affected code.
2. Collect questions per `docs/ai/skills/implementation-clarify.md`; answer them
   yourself from the codebase where you can (by reading the real code).
3. To the human in a batch: what is unresolved, all red flags (self-answering
   does not close them), and debatable self-answers phrased as "I believe X,
   confirm."
4. Repeat until clean. Record the answers in the run file as decisions.

### 2. Plan (gate)

1. Run the entire `docs/ai/commands/codex-plan.md` process: the questioning
   call to Codex, effort choice, the plan, and the reconciliation loop. Pass the
   phase 1 decisions as settled.
2. Gate: show the human the summary, the assumptions, and the questions. Edits →
   re-plan through Codex. Record the approval in the run file.

### 3. Build (loop)

1. State the model/effort: default opus/`high`; `xhigh`/`max` by the cost of a
   mistake; fable only for the hardest long-running tasks; mechanics → opus/`low`.
2. Launch the build subagent: strictly per the plan, following
   `docs/ai/skills/build.md` and the project rules, a minimal scoped diff,
   `<check>` until green, **do not commit** (the orchestrator commits). Split a
   large plan into steps — one subagent per step, effort per step.
3. Reconcile the implementation against the plan yourself and output the
   mandatory line:
   `Plan reconciliation: matches` or
   `Plan reconciliation: deviations — [...]`.
   - Technical deviations (unfinished, extra, off-plan) → return concrete fixes
     to the subagent, repeat the loop.
   - Semantic deviations and forks (the plan is inaccurate, something new
     surfaced) → to the human in a batch; if the answers change scope → return
     to phase 2 (re-plan), otherwise → fix via the subagent.
4. Clean reconciliation → commit + run file.

### 4. Review (round N)

1. Freeze a snapshot: the sha of the last commit.
2. Scope: round 1 — the whole task diff (`<base>...HEAD`); round N+1 — the delta
   from the last reviewed sha; pass the findings registry to the reviewers as
   "already known" context.
3. Run the `docs/ai/commands/review-full.md` process: Codex correctness
   (+security by risk signals) ∥ design subagent, in parallel.
4. Dedup per the review-full rules **plus against the registry**: do not reopen
   `rejected`/`wontfix`; if `fixed` but it came back → status `regression`.
5. Write every round into the one review file for the task, each round as a
   `## Round N (<sha>)` section; do not create a new file.

### 5. Triage (gate)

1. Enter new findings into the run file registry (ID, source, severity, file,
   gist, status `open`).
2. To the human, compactly per open finding: the gist plus solution options in
   1–2 lines, grouped by severity. The human's decision: `accepted` (fix) /
   `rejected` (finding is wrong) / `wontfix` (correct, but we will not fix).
3. Do not hide Nit/Optional/FYI: if there is no Critical/Required, still show the
   rest and ask whether to fix or skip. Do not slip silently into done.

### 6. Fix (loop)

1. `accepted` findings → build subagent (effort by the cost of a mistake in the
   fixes), minimal edits, `<check>` green.
2. Commit; in the registry `accepted` → `fixed`; update the run file.
3. Return to phase 4 as a new round (on the delta). The review+fix loop runs
   while there are open/accepted Critical/Required findings or the human gives
   new edits. The human ends the loop: by a stop or by confirming the remaining
   findings.

### 7. Done

Criteria (all at once):

- no Critical/Required findings in status `open`/`accepted`/`regression`;
- `<check>` green;
- the last plan reconciliation is clean;
- the human has confirmed the remaining Nit/Optional/FYI (fix or skip).

Finish: run file → `done`, final commit. In chat, a final summary: what was
done, the plan, the review files, the registry, the branch/sha. Push, PR, and
apply to main only on an explicit request.

## Escape hatches

Do not spin the loop silently — go to the human with a question if:

- the build subagent fails or twice in a row fails to get `<check>` green for the
  same reason;
- `<check>` is red because of infrastructure or pre-existing problems, not the
  task;
- the plan turns out to be wrong in substance, not just at one point;
- scope grows beyond the plan;
- two review+fix rounds in a row do not reduce open Critical/Required;
- Codex is rate-limited — ask: wait, or continue without Codex review (a note in
  the run file is mandatory).

## Gate messages

Every gate: a short status (phase, round, what was done, what is next) plus
questions in a batch. Do not retell whole reports — give paths to the artifacts
and the gist.
