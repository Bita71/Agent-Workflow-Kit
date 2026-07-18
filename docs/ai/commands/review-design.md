# review-design

The current host's read-only `review-design` agent reviews the changed diff.

## Scope

1. Determine the changed files: `git diff --name-only`.
2. If the diff is empty, check the staged diff: `git diff --staged --name-only`.
3. If the staged diff is empty too, say briefly: `No changes for design review`.
4. Review only the changed files and their nearest dependencies.
5. Do not review the whole project.

## Process

Follow `docs/ai/skills/review-design.md`.

Focus:

- architecture and module/layer boundaries;
- public API;
- UX consistency;
- simplification;
- readability;
- performance.

## Artifact

Write the result to `docs/ai/reviews/YYYY-MM-DD-short-task.design.review.md`.

If a shared review file already exists and the user asks for a merged report,
extend it with a `Design` section.

## Chat result

Return briefly:

- the path to the review file;
- the counts of `Critical`, `Required`, `Nit`, `Optional`, `FYI`;
- 1–3 top findings, if any.
