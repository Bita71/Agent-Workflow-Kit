# <Short one-line title>

## What's needed

<The problem and the desired outcome, in your own words.>

## Context

- <Anchors in code: files, modules, layer, what to look at.>
- <Similar existing implementation to reuse, if any.>

## Constraints / do not

- <What not to touch, which approaches are off-limits, scope bounds.>
- <No new dependencies. User-facing text via the i18n layer, not hardcoded.>

## Done criteria

- <How to know it's done, in terms of behavior.>
- <`<check>` is green.>

<!--
Naming: put new briefs in briefs/new/ with a kebab-case name by task, NO date
(e.g. fix-list-empty-state.md). The filename → slug → branch auto/<slug> and
logs/<slug>/. Keep the slug stable across the whole lifecycle.

A good brief: give code anchors, bound the scope, list required UI states
(loading/error/empty/disabled/success) for screen work, state done-criteria as
behavior not implementation, size it to one night, don't change dependencies,
and NEVER put secrets in it — the agent reads the brief whole.
See docs/ai/recipes/night-runner-briefs.md for the full guide.
-->
