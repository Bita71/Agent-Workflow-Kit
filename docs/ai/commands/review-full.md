# review-full

The current host orchestrates correctness, optional security, and design review,
deduplicates the results, and writes one report. Reviewers are read-only.

## Scope

1. Use the user-specified range when provided.
2. Otherwise review unstaged changes, then staged changes if unstaged is empty.
3. Review changed files and directly affected paths, not the whole repository.
4. Resolve `BASE_REF` from config only for a task-branch range.

## Decisions

Read config and active profiles, then state:

```text
Review: correctness[+security] <model/effort> | design <model/effort>
```

- Correctness uses `CORRECTNESS_MODEL`.
- Security uses `SECURITY_MODEL` and runs only for risk signals from
  `docs/ai/skills/review-security.md` or an explicit user request.
- Design uses `DESIGN_MODEL` through the host's tracked `review-design` agent.
- Resolve effort through `DEFAULT_EFFORT` and `CODEX_MAX_EFFORT`.

## Launch

Run correctness (+security when selected) and design against the same frozen scope.
Parallelize when the host supports it; otherwise run sequentially and keep the
scope identical.

1. Codex correctness/security follows `docs/ai/agents/cli.md`, active profiles,
   and the review skills. It returns text only.
2. The native `review-design` agent follows
   `docs/ai/skills/review-design.md` and returns text only.

Every pass begins with:

```text
Critical: N | Required: N | Nit: N | Optional: N | FYI: N
```

## Deduplication

- Same location and failure/risk -> one finding with combined sources.
- Resolve disputed severity by reading the code path, not by taking the maximum.
- Keep unique, evidenced findings and remove speculation.
- Source is `correctness`, `security`, `design`, or a `+` combination.

## Artifact

The host writes `docs/ai/reviews/YYYY-MM-DD-short-task.review.md` with the summary,
severity sections, file, evidence/gist, source, and concrete fix. Reviewers never
write this file.

If clean, state which passes ran and write `No critical problems found`.

## Chat result

Return the artifact path, severity counts, and up to three top findings. Do not fix
code without a separate user request.
