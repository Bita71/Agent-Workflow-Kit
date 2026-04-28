---
description: Run correctness and design review over the current diff
---

Review only changed files. Determine scope from the current diff or user-provided files.

Invoke two subagents in parallel and pass the same file list to both:

- `review-correctness`
- `review-design`

## Merge

Return one report:

```text
Critical: N | Required: N | Nit: N | Optional: N | FYI: N

### Critical
[merge-blocking]

### Required
[must fix]

### Nit
[minor author-choice]

### Optional
[improvements]

### FYI
[context]
```

Each finding must cite the file, reviewer, issue, severity, and concrete fix. Drop findings without code evidence.
