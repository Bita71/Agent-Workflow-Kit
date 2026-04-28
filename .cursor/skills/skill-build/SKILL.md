---
name: build
description: Route implementation work to standard, complex, or hardcore builders; finish with verification.
---

# Build Routing

Use this for `/build` and `/build-manual`.

## Step 1: Clarify

Read `.cursor/skills/skill-implementation-clarify/SKILL.md`.

Ask 1-3 blocking questions before routing only when the task can materially go wrong without the answers. If the task is clear, route immediately.

## Step 2: Route By Signals

Choose exactly one level. If unsure between two levels, choose the higher one.

### `build-standard`

Default when no higher signal exists.

- 1-2 files.
- Clear scope.
- Small feature, isolated fix, small UI change, or straightforward refactor.
- No public API change.
- No new user flow or state machine.
- No meaningful architecture trade-off.

### `build-complex`

Use when at least one signal exists:

- 3+ files.
- Public API change.
- New user flow, screen, form, or stateful interaction.
- Meaningful architecture decision.
- Non-trivial edge cases: loading, errors, empty state, partial data.
- Integration across multiple modules or layers.

### `build-hardcore`

Use when at least one signal exists:

- Cross-module refactor or contract migration.
- Security-sensitive work: auth, payments, permissions, secrets, personal data.
- Large feature: 7+ files or a new module from scratch.
- Unclear requirements with several viable approaches.
- Many edge cases, races, retries, or idempotency concerns.
- Contract consumed by many places.

## `/build` Mode

1. Tell the user: `Routing: build-<level> - <one-sentence reason>`.
2. Run exactly one builder agent for the selected level.
3. Do not implement code yourself.
4. After the builder completes, run `verifier`.

## `/build-manual` Mode

1. Tell the user: `Mode: build-<level> - <one-sentence reason>`.
2. Implement in the current chat.
3. Do not call builder agents.
4. After implementation, run `verifier`.

## Final Verification

Every build task ends with `verifier` or `/verify`.

Do not consider the flow complete until verification finishes or you clearly report why it could not run.
