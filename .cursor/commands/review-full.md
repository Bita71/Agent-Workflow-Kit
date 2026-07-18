# review-full

Orchestrate a full review of the current diff: Codex correctness (+ security by
risk signals) in parallel with a strong-model design review, then deduplicate into
one report. No code is edited in this command.

Follow `docs/ai/commands/review-full.md` exactly. Use `docs/ai/agents/cli.md` for
Codex CLI calls, the `review-design` subagent for design, and the review skills
(`docs/ai/skills/review-correctness.md`, `review-security.md`, `review-design.md`).
Write the merged report to `docs/ai/reviews/YYYY-MM-DD-short-task.review.md`.
