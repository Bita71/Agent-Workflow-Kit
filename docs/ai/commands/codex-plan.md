# codex-plan

Claude orchestrates planning: it closes out questions before the plan, Codex
builds the plan through the CLI, Claude reconciles the result, refines it through
Codex, and writes the artifact. Claude does not write the plan itself.

## Roles

- **Claude (this command)**: context, the question loop, effort choice,
  launching Codex, reconciling the plan, writing the artifact, the gate with the
  human.
- **Codex** (`gpt-5.5`, calls strictly per `docs/ai/agents/cli.md`): the
  clarifying questions and the plan itself, per `docs/ai/skills/plan.md`.

## Process

### 1. Context

Read the task and the affected code. Take `docs/ai/rules/project.md` into
account, and for source code, `docs/ai/rules/coding-rules.md`.

### 2. Question loop (before the plan)

1. Collect your own questions per `docs/ai/skills/implementation-clarify.md`.
2. In a separate Codex call (effort `medium`), request its questions: pass the
   task and context, ask for **clarifying questions only**, with no plan or code.
3. For each question (yours and Codex's), first try to answer it yourself **from
   the codebase** — by reading the real code, not from memory.
4. Bring to the human in **a single batch**, grouped (AskUserQuestion):
   - questions you could not answer with confidence;
   - **all red flags** from implementation-clarify (security,
     security-sensitive domains, a visible UX fork, a new public API) — even if
     the code offered a plausible answer, self-answering does not close a red
     flag;
   - the answers you found for debatable spots — phrased as "I believe X,
     confirm."
5. Repeat the loop until no open questions remain.

If after steps 1–3 no questions remain and there are no red flags, output one
visible line `Clarification: no red flags → accepted defaults [X, Y]` and
continue.

### 3. Effort

Choose the effort of the planning call per the criteria in
`docs/ai/commands/choose-model.md`: default `high`; `max` for
money/security/migrations/highest cost of a mistake; `medium` for a routine task
with clear requirements. The model is always `gpt-5.5`.

State the choice in one line: `Plan: gpt-5.5, effort <X> — <why>`.

### 4. Plan through Codex

Call Codex per `docs/ai/agents/cli.md`. In the prompt include:

- follow `docs/ai/skills/plan.md` and `docs/ai/agents/codex-plan.md`;
- the task and **all the answers you gathered** — as settled decisions, not as
  open questions;
- residual minor uncertainties — into a "Questions and assumptions" section with
  an explicit assumption for each;
- do not write code, output only the plan in Markdown.

### 5. Reconciliation (loop until convergence)

Check the plan yourself:

- it covers the task and all the human's answers, and contradicts none of them;
- scope has not grown or shrunk;
- the files/modules are real, the steps are checkable;
- there are no silent assumptions on red flags.

Found problems — return to Codex for refinement with a new call carrying concrete
remarks and the current plan. Repeat until the reconciliation is clean. If the
plan surfaced new substantive questions — return to step 2.

### 6. Artifact and gate

1. Write the plan to `docs/ai/plans/YYYY-MM-DD-short-task.plan.md` (Codex does
   not write to read-only files — you write it; do not edit the plan content).
2. Show the human: the path, a 3–6 point summary (decision, scope boundaries,
   phases, key risks/checks), the key assumptions, and any remaining questions.
3. The human's edits → a new loop through Codex (steps 4–5). Do not edit the plan
   yourself.

## Chat response format

```markdown
Plan: `docs/ai/plans/YYYY-MM-DD-short-task.plan.md`

Summary:

- [core decision]
- [what is in and out of scope]
- [main phases]
- [key risk and check]

Assumptions: [key assumptions from the plan, if any]
Questions: [remaining questions, if any]
```
