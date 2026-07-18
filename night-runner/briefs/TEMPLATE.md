# <Short one-line title>

## What's needed

<The problem and the desired outcome, in your own words.>

## Context

- <Anchors in code: files, modules, layer, what to look at.>
- <Similar existing implementation to reuse, if any.>

## Constraints / do not

- <What not to touch, which approaches are off-limits, scope bounds.>
- <No new dependencies. Follow active profiles and project rules.>

## Done criteria

- <How to know it's done, in terms of behavior.>
- <The configured `CHECK_COMMAND` is green.>

<!--
Naming: put new briefs in briefs/new/ with a kebab-case name by task, NO date
(e.g. reject-malformed-record.md). The filename -> slug -> branch auto/<slug> and
logs/<slug>/. Keep the slug stable across the whole lifecycle.

A good brief gives code anchors, bounds scope, states applicable behavior/failure
states, defines done criteria as behavior, fits one night, does not change
dependencies, and never contains secrets.
See docs/ai/recipes/night-runner-briefs.md for the full guide.
-->
