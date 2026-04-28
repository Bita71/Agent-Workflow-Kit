---
name: plan
description: Create implementation plans with clarify, optional mini-spec, output artifact, and build routing.
---

# Plan

Create a plan. Do not write code unless the user explicitly changes the task from planning to implementation.

## Input

- User request.
- Relevant files, designs, issues, logs, or prior decisions.
- Mini-spec from the orchestrator, if one exists.

## Clarify

Use `.cursor/skills/skill-implementation-clarify/SKILL.md`.

Ask 1-3 blocking questions only when the plan could materially change based on the answer. If the task is clear, proceed.

## Mini-Spec Gate

Create a mini-spec before the plan if any condition is true:

- 3+ files are likely to change.
- A public API or persisted contract changes.
- A new user flow or state machine is introduced.
- The work is security-sensitive.
- Requirements are unclear and multiple approaches are plausible.

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

Skip the mini-spec for small, clear tasks.

## Required Output Artifact

1. Mini-spec, if created.
2. Implementation steps.
3. File list: create, change, delete.
4. API and contracts: what changes and what stays stable.
5. Edge cases.
6. Risks and mitigations.
7. Out of scope.
8. Done criteria: measurable, not vague.
9. Test plan: unit, integration, e2e, manual, CI.
10. Final verification command.
11. Build routing as the final section:
    - exactly one of `build-standard`, `build-complex`, `build-hardcore`;
    - model preset, if the repository pins models; otherwise write `tool default`;
    - one-sentence reason.

## `/plan` Orchestration

Run `plan-gpt` by default.

Run `plan-claude` only if at least two escalation signals exist:

- security-sensitive flow;
- 7+ affected files or broad refactor;
- public API changes in multiple places;
- unresolved architecture trade-offs after clarify.

If both planners run, merge them into one artifact. Do not return a model-by-model debate.

## `/plan-manual` Orchestration

Do not call planner agents.

Create the full output artifact in the current chat.

## Verification

- Every step maps to concrete files or modules.
- Done criteria are measurable.
- Edge cases match the user flows.
- Risks include mitigations.
- Test plan covers acceptance criteria.
