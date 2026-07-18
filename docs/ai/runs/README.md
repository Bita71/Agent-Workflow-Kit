# Runs

Progress files for `/symphony` runs (`docs/ai/commands/symphony.md`).

Filename format: `YYYY-MM-DD-short-task.symphony.md`.

The file is the run's resumable state: a fresh session reads "State" and continues
from the recorded phase without repeating closed gates. It's updated after every
phase and every round, and committed together with the phase.

## Format

```markdown
# Symphony: <short-task>

## State

| Field            | Value                                                       |
| ---------------- | ----------------------------------------------------------- |
| Task             | <statement or link>                                         |
| Phase            | clarify / plan / build / review / triage / fix / done       |
| Review round     | <N>                                                         |
| Branch / worktree| <branch>, <path or "—">                                     |
| Base             | <resolved BASE_REF and sha at task start>                   |
| Last commit      | <sha>                                                       |
| Reviewed sha     | <sha of last round or "—">                                  |
| Plan             | docs/ai/plans/<...>.plan.md                                 |
| Review           | docs/ai/reviews/<...>.review.md                             |
| Models           | planner/build/review role values from config + efforts      |

## Human decisions

- <gate>: <question> → <answer>

## Findings registry

| ID    | Source      | Severity | File  | Summary | Status |
| ----- | ----------- | -------- | ----- | ------- | ------ |
| R1-01 | correctness | Required | <...> | <...>   | open   |

## Journal

- [x] clarify — <outcome>
- [x] plan — approved, <path>
- [ ] build
- [ ] review (round 1)
- ...

## Files

- <affected files>
```

## Finding statuses

- `open` — new, awaiting triage;
- `accepted` — human accepted it, fixed in the fix phase;
- `rejected` — human judged the finding wrong; do not reopen;
- `wontfix` — correct, but we won't fix it; do not reopen;
- `fixed` — fixed and committed;
- `regression` — was `fixed`, came back in a later round.

ID: `R<round>-<number>` — keyed by the review round the finding first appeared in.
