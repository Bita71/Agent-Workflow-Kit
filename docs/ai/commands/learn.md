# learn

Based on the **entire chat context**, propose only what is worth capturing in the
repository for the long term. This is a manual command at the end of a session,
not auto-learning. **Do not apply** the edits yourself — only propose; the user
copies, edits, or rejects.

## Usefulness filter

Propose a change only if it passes every point:

1. It will recur in future tasks and save time or reduce the risk of a mistake.
2. It is concrete enough that an agent can follow the rule without guessing.
3. It is not a restatement of existing rules, the README, or recipes.
4. It does not lock in a one-off decision, a temporary agreement, or a matter of
   taste.
5. It does not complicate the process more than it helps.

If there are no useful changes — say so directly: `Nothing to capture`.

## What to look for in the session

- A repeatable pattern that will be useful in future tasks.
- A mistake or trap worth not repeating.
- A non-obvious debugging technique or check that saved time.
- An architectural decision or ownership boundary, if it will recur.
- An improvement to an existing flow: `/plan`, `/build`, `/review-full`,
  `/symphony`.

## What you may propose

| Target                  | When                                                                         |
| ----------------------- | ---------------------------------------------------------------------------- |
| `docs/ai/rules/*.md`    | A repeatable **invariant** / prohibition / mandatory step (narrow, no fluff). |
| `docs/ai/skills/*.md`   | A reusable workflow / checklist / specialized process.                       |
| `docs/ai/commands/*.md` | A new command or a change to a core workflow.                                |
| `docs/ai/agents/*.md`   | An agent role, model, or ownership boundary.                                 |
| `docs/ai/README.md`     | A link to a new/important recipe section or a change to the docs "map".      |
| `docs/ai/recipes/*.md`  | **How to do X**: steps, commands, checklist, pitfalls, without duplicating existing content. |

## Cleaning up current rules

Before adding, check the current rules and concepts:

- if the new rule duplicates an existing one — propose replacing/condensing the
  old text, not adding a second layer;
- if a rule is stale, too broad, or conflicts with the actual flow — propose
  deleting or rewriting it;
- if several rules say the same thing in different words — propose one final
  wording;
- if the knowledge lives better in a recipe, do not move it into rules;
- if the knowledge lives better in a skill, do not move it into a command or
  rules;
- if one principle recurs across several skills/recipes — propose extracting it
  into `docs/ai/rules`;
- if the knowledge appears in only one skill/recipe — leave it there, do not
  promote it into rules.

## What not to propose

- Automatic hooks / Stop-hook learning / learned/imported skill storage.
- New files in the style of a `learned` skills folder inside the repository.
- Generic "write clean code" advice, if it is already covered by rules/skills.
- Changes that lock in only the current one-off dispute or preference.

## How to respond

1. 1–3 sentences: what from the session is genuinely worth capturing. If nothing
   — no extra points.
2. For each proposal: the **action** (`add`, `replace`, `delete`, `condense`),
   the **file**, the **why**, and a **draft** of the text ready to paste.
3. At most 3 proposals per `/learn`; one strong change beats a list of weak ones.
