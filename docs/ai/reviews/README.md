# Reviews

Reviews are written here as artifacts of the multi-agent workflow.

Filename format: `YYYY-MM-DD-short-task.review.md`.

A full review is orchestrated by Claude through `/review-full`
(`docs/ai/commands/review-full.md`): Codex always does correctness and does
security when risk signals are present, the strong model does design review in
parallel, and the result is a single deduplicated report. A standalone
`/review-design` remains for design-only reviews and may write into the same
review file or a separate `*.design.review.md`.
