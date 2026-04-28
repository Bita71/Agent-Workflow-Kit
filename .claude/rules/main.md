# Main Rules

## Core

- Make narrow changes tied to the user's request.
- Do not perform opportunistic refactors.
- If the user names a command or subagent, use it.
- Ask 1-3 blocking questions only when the task can go materially wrong without the answers.
- Do not add dependencies, commit, or push without an explicit request.
- Avoid speculative abstractions, configurability, and fallbacks unless the task needs them.
- Simplify before growing a solution.
- For multi-step work, define verifiable done criteria before editing.

## Architecture

- Prefer existing project patterns, helpers, and module boundaries.
- Keep business logic out of shared utility layers unless the repository allows it.
- Import through public APIs where the project has them.
- Do not leak internal implementation paths across module boundaries.
- Update public exports and documentation when public contracts change.

## TypeScript And Data

- Strict TypeScript: avoid `any`, meaningless casts, and unsafe non-null assertions.
- Prefer `unknown`, `satisfies`, and explicit contracts.
- Treat external data as untrusted.
- Keep DTOs, query keys, and mapping close to the data source.

## UI

- Prefer existing UI primitives before custom controls.
- Do not break accessibility contracts.
- Avoid magic strings where the project has localization or copy conventions.
- Keep React hooks predictable: no effects for derived state or event-handler logic.
- Prefer CSS for layout and animation when appropriate.
- Use existing design tokens instead of hardcoded colors and spacing.

## Code Style

- Keep data flow simple and direct.
- Name variables clearly.
- Comments explain why, not what.
- No dead code or commented-out code.

## Verification

- After code changes, run the repository's standard check command.
- Before a pull request, run the production or full validation command if one exists.
- After code changes, invoke the `verifier` subagent as the final step.
