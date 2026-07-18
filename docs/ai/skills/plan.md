# Plan

Produce a concrete, verifiable implementation plan tied to real repository files
and behavior. Do not write code or launch other agents.

## Context

1. Read `.agent-workflow-kit/config.conf`.
2. Load `core` and only the profiles listed in `PROFILES`.
3. Read `docs/ai/rules/project.md` and
   `docs/ai/rules/coding-rules.md`.
4. Resolve `BASE_REF` only if the task needs a Git range.

## Clarification gate

Use `docs/ai/skills/implementation-clarify.md`. Ask only unresolved material
questions; do not force stack-specific questions onto an unrelated task.

## Process

1. **Requirements:** state the goal, required behavior, constraints, assumptions,
   exclusions, and measurable done criteria.
2. **Repository evidence:** find similar implementations, affected files,
   boundaries, consumers, and existing checks. Do not invent paths.
3. **Applicability:** identify only the capabilities involved (for example public
   API, persistence, user interface, concurrency, deployment, or external input)
   and load their active-profile rules.
4. **Architecture, when needed:** describe current state, the decision, boundaries,
   contracts, data/control flow, and real alternatives. Skip this section for a
   small local change.
5. **Steps:** order work by actual dependencies. Each step names files or an
   explicit discovery action, explains why it exists, and has a risk level and a
   verification method.
6. **Verification:** cover changed behavior with the repository's applicable test
   layers and finish with `CHECK_COMMAND` unless configured as `none`.

Use an architecture section when a public contract, multiple boundaries, a new
workflow, a trust boundary, a migration, concurrency, or a notable trade-off is
involved.

## Artifact format

Use `ARTIFACT_LANGUAGE` from config.

```markdown
# Implementation plan: [task]

## Goal
[outcome]

## Requirements
- [requirement]

## Assumptions
- [assumption or "none"]

## Out of scope
- [excluded work]

## Affected files
- `[path]` - [reason]

## Architecture and contracts
[only when needed]

## Work plan
### Phase 1: [name]
1. **[step]** (`path`)
   - Action: [change/discovery]
   - Why: [reason]
   - Dependencies: [none or step]
   - Risk: low | medium | high - [reason]
   - Verify: [check]

## Edge cases
- [applicable failure/boundary case]

## Risks and mitigations
- **Risk:** [description]
  - Mitigation: [action]

## Test plan
- [applicable tests/checks]
- Project check: `CHECK_COMMAND`

## Done criteria
- [ ] [measurable result]
- [ ] Configured verification passes
```

## Chat response

After creating or updating the artifact, always return:

1. The `.plan.md` path.
2. A self-contained summary of 3-6 points covering the decision, scope,
   phases, and primary risks/checks.

## Quality check

- Every step is tied to real files or an explicit search step.
- No unlisted profile or foreign stack is assumed.
- Risks have mitigations and done criteria have verification.
- Optional architecture content appears only when complexity requires it.
- The final configured project check is present.
