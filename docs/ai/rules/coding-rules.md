# Coding Rules

This is the repository-owned overlay over the active profiles. The defaults below
are safe for an uncustomized project; replace or extend them only with rules that
an agent can verify from this repository.

## Architecture and boundaries

- Discover existing modules, packages, layers, and public entrypoints before
  editing them.
- Preserve the repository's dependency direction and visibility rules.
- Do not create a new boundary or abstraction unless the task requires it.

## Language and toolchain

- Match the language version, strictness, formatter, linter, and build system
  already configured in the repository.
- Do not bypass the type system, compiler, validator, or policy engine without a
  documented guarantee and a local reason.
- Prefer project-supported APIs over introducing a parallel toolchain.

## Interfaces and external behavior

- Preserve public contracts unless the task explicitly changes them.
- Treat compatibility, migration, and failure behavior as part of a contract.
- Apply interface/UI-specific rules only when an active profile makes them
  relevant.

## Data and domain behavior

- Preserve units, precision, nullability, ownership, and validation across
  boundaries.
- Do not invent domain policy. Read it from code, tests, documentation, or an
  active profile; ask when it remains ambiguous.

## Code style

- Match neighboring naming, file layout, test placement, and comment density.
- Point to formatter/linter configuration instead of restating it here.
- Comments explain constraints and intent, not obvious syntax.

## Reuse ladder

Before writing non-trivial code, walk this list top-down and stop at the first
step that applies:

1. **Is it needed?** If it does not follow from the task, do not write it.
2. **Does it already exist?** Reuse a local primitive, helper, or neighboring
   pattern.
3. **Does the platform or language solve it?** Prefer the supported standard.
4. **Does an installed dependency solve it?** Use it; do not add a dependency.
5. **Can it be simpler?** Avoid an abstraction when a direct local change closes
   the task.
6. **Only then** write the minimal implementation for the current case.
