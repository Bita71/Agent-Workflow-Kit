# Build

Implement the user's task in the current workspace. If an approved plan exists,
follow it; otherwise use the smallest plan appropriate to the change.

## Context

Before editing:

1. Read `.agent-workflow-kit/config.conf`.
2. Load `core` and only the profiles listed in `PROFILES`.
3. Read `docs/ai/rules/project.md`,
   `docs/ai/rules/coding-rules.md`, and the target files.
4. Find the nearest existing pattern and affected consumers/boundaries.

## Clarification gate

Run `docs/ai/skills/implementation-clarify.md` and print its visible result before
the first edit. Questions are required only for unresolved red flags. If the user
accepted defaults, state the reversible defaults used.

## Plan before code

- A small, local task may use a short internal plan.
- For multiple modules, a public contract, a migration, a trust boundary, an
  irreversible action, or a notable trade-off, print a short plan before editing.
- The plan names affected files/modules, order, applicable edge cases, and checks.

## Implementation

- Make a minimal scoped diff; do not add dependencies, commit, or push without
  explicit authority.
- Follow the actual dependency order of the change rather than a fixed stack
  sequence.
- Use the reuse ladder in `docs/ai/rules/coding-rules.md`; do not duplicate it in
  this skill.
- Preserve public behavior unless the task explicitly changes it.
- Apply TDD or another executable-specification loop when it is the repository's
  active convention or when a high-risk behavior is most safely defined by a
  failing test first.
- Apply interface, browser, database, deployment, or domain-specific practices
  only through active profiles and local rules.

## Tests and checks

Follow `docs/ai/rules/testing.md` and active profiles.

1. Run the narrowest relevant checks while iterating.
2. Add/update tests for changed behavior where the repository can express them.
3. Run the configured `CHECK_COMMAND` after substantive changes unless it is
   `none` for a documentation-only repository.
4. Fix failures introduced by the change and rerun the affected checks.
5. Record infrastructure/pre-existing failures with the exact command and reason.

Sandbox-specific troubleshooting belongs in `docs/ai/recipes/sandboxes.md`, not
in this core workflow.

## Final response

Return briefly:

- what changed;
- key files;
- checks that passed;
- anything that could not be verified and why.
