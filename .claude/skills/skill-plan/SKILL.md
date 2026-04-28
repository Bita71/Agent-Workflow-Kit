---
name: plan
description: Create implementation plans with clarify, optional mini-spec, output artifact, and build routing. Used by /plan and /plan-manual.
---

# Plan

Create a plan. Do not write code unless the user explicitly changes the task from planning to implementation.

## Clarify

Use `.claude/skills/skill-implementation-clarify/SKILL.md`.

Ask 1-3 blocking questions only when the plan could materially change based on the answer.

## Mini-Spec Gate

Create a mini-spec before the plan if any condition is true:

- 3+ files are likely to change;
- a public API or persisted contract changes;
- a new user flow or state machine is introduced;
- the work is security-sensitive;
- requirements are unclear and multiple approaches are plausible.

Mini-spec format:

```text
## Mini-Spec
- Goal: [one sentence]
- Non-goals: [explicitly out of scope]
- User flows / states: [main scenarios]
- Data and boundaries: [API, storage, contracts]
- Acceptance criteria: [concrete, testable]
- Risks: [what can break]
```

## Required Output Artifact

1. Mini-spec, if created.
2. Implementation steps.
3. File list: create, change, delete.
4. API and contracts.
5. Edge cases.
6. Risks and mitigations.
7. Out of scope.
8. Done criteria: measurable.
9. Test plan: unit, integration, e2e, manual, CI.
10. Final verification command.
11. Build routing as the final section:
    - exactly one of `build-standard`, `build-complex`, `build-hardcore`;
    - model preset, if the repository pins models; otherwise write `tool default`;
    - one-sentence reason.

## `/plan` Orchestration

Invoke the `plan-gpt` subagent by default.

Invoke the `plan-claude` subagent only if at least two escalation signals exist:

- security-sensitive flow;
- 7+ affected files or broad refactor;
- public API changes in multiple places;
- unresolved architecture trade-offs after clarify.

If both planners run, merge them into one artifact.

## `/plan-manual` Orchestration

Do not invoke planner subagents. Create the full output artifact in the current chat.
