# Coding Rules

> **Template — fill this in for your repository.** The skills, commands, and agent
> roles all reference this file for language/framework/UI conventions. `project.md`
> holds the tool-agnostic invariants; this file holds the ones specific to your
> stack. Delete the guidance comments once you've written the real rules. Keep it
> tight — rules the agent can follow without guessing, not a style essay.

## Architecture & boundaries

<Describe your architecture: layers/modules, allowed dependency directions, what a
module's public API is and how it's exported, what may not import what. If you use
a layered scheme (hexagonal, clean, layered, etc.), state the layer order and the
import rules the agent must not violate.>

## Language & types

<TypeScript/other: no new `any`, no unsafe casts without justification, no
non-null assertion without a guarantee, keep DTO types intact across boundaries.
State your strictness expectations.>

## Framework / UI

<React/Vue/other component rules: required UI states (loading, error, empty,
disabled, success), effect/state discipline, list keys, avoiding needless
re-renders. Component/presentational conventions and where logic lives.>

## Styling

<Styling system: use design tokens / CSS variables, no hardcoded colors or
spacing, where styles live, class-naming or module conventions.>

## User-facing text (i18n)

<No hardcoded UI strings — route them through your i18n layer. Naming of keys /
namespaces, where translations live, how to reference them.>

## Dates, money & formatting

<Use your project's date library, not the platform primitive, if you have one.
Money/decimal handling library and rounding conventions. Shared formatters to
reuse instead of re-implementing.>

## Code style

<Naming, file layout, colocated tests/stories, comment density. Match the
surrounding code. Point at the formatter/linter config rather than restating it.>

## Reuse ladder

Before writing new non-trivial code, walk this ladder top-down and stop at the
first step that applies:

1. **Is it needed at all?** If the requirement doesn't follow from the task, don't
   write it (YAGNI).
2. **Already in the codebase?** Reuse a shared primitive, existing hook/helper, or
   a neighbouring module's pattern.
3. **Solved by the platform/language?** A native API or a language feature instead
   of a hand-rolled wrapper.
4. **Solved by an installed dependency?** Use it. Don't add a new dependency.
5. **Can it be shorter?** If one expression closes the task, don't grow an
   abstraction.
6. **Only then** write the minimal implementation for the current case, no
   speculative generalization.
