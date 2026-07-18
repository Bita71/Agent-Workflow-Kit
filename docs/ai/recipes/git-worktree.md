# Git Worktree: isolated workspace workflow

An isolated checkout for work that must not touch the current `REPO_ROOT`:
experiments, parallel tasks, comparing approaches. If a normal branch in the base
workspace is enough, you do not need a worktree. Create one only when the user
asks. Official docs: [git worktree](https://git-scm.com/docs/git-worktree).

## Terms and flow

| Name                 | Meaning                                                         |
| -------------------- | -------------------------------------------------------------- |
| `REPO_ROOT`          | The base checkout (`git rev-parse --show-toplevel`).           |
| `WORKTREE_PATH`      | A separate checkout created via `git worktree add`.            |
| `WORKTREE_ID`        | A short session id (`<name>-<8hex>`).                          |
| `BASE_REF`           | Resolved from config (`origin/HEAD`, current branch, or pin).  |
| `WORKTREE_START_REF` | The ref for `git worktree add` (`HEAD`, `BASE_REF`, or SHA).   |

```text
create worktree  -> edits only in WORKTREE_PATH
apply worktree   -> move the diff into REPO_ROOT (unstaged)
delete worktree  -> remove the separate checkout
```

While a `WORKTREE_PATH` mapping exists in the chat, do not read, write, or run git
in `REPO_ROOT` for this task, except during the apply step. Record the mapping
(`REPO_ROOT`, `WORKTREE_PATH`, `WORKTREE_ID`, `WORKTREE_START_REF`) in the chat.

## 1. Create

```bash
set -euo pipefail
BASE_REF="<resolved BASE_REF from config>"
WORKTREE_ID="<name>-<8hex>"
WORKTREE_START_REF="${WORKTREE_START_REF:-$BASE_REF}"
REPO_ROOT="$(git rev-parse --show-toplevel)"
REPO_BASENAME="$(basename "$REPO_ROOT")"
WORKTREE_DIR="$(dirname "$REPO_ROOT")/${REPO_BASENAME}-worktrees/$WORKTREE_ID"
mkdir -p "$(dirname "$WORKTREE_DIR")"
git worktree add --detach "$WORKTREE_DIR" "$WORKTREE_START_REF"
```

If the sandbox will not let you create a directory next to the repository, use
`/tmp/<repo>-worktrees/<WORKTREE_ID>` or request permissions.

Right after creation: switch to `WORKTREE_PATH` and run setup (install
dependencies, without the sandbox — see pitfalls). If setup fails, stop and do not
touch `REPO_ROOT`. Report the mapping, `HEAD_COMMIT`, and setup status in the chat.

## 2. Apply

Apply **only when the user explicitly asked** to move the diff into `REPO_ROOT`.
Merging the resolved base into the worktree, resolving conflicts, and running
checks are not apply; do not move changes into the base checkout on your own.

It moves **tracked** changes via a temporary commit + `cherry-pick --no-commit`,
and **untracked** changes by copying. In `REPO_ROOT` the changes stay unstaged: the
user reviews the diff and commits it. After apply, ask whether to delete the
worktree.

A linked worktree's `git rev-parse --git-common-dir` can return an absolute path,
while the base checkout's is a relative `.git`, so paths are normalized first
(`resolve_git_common`) rather than a naive `cd $(git rev-parse --git-common-dir)`.

```bash
set -euo pipefail
SOURCE_WORKTREE_PATH="<source>"
BASE_WORKTREE_PATH="<base-checkout>"
SOURCE_ABS="$(cd "$SOURCE_WORKTREE_PATH" && pwd -P)"
BASE_ABS="$(cd "$BASE_WORKTREE_PATH" && pwd -P)"

resolve_git_common() {
  local dir="$1"
  local common
  common="$(git -C "$dir" rev-parse --git-common-dir)"
  if [[ "$common" != /* ]]; then
    common="$(cd "$dir/$common" && pwd -P)"
  else
    common="$(cd "$common" && pwd -P)"
  fi
  echo "$common"
}

SOURCE_COMMON="$(resolve_git_common "$SOURCE_ABS")"
BASE_COMMON="$(resolve_git_common "$BASE_ABS")"
if [ "$SOURCE_COMMON" != "$BASE_COMMON" ]; then
  echo "ERROR: source and base checkout do not share the same repository." >&2
  exit 1
fi

UNTRACKED_FILES="$(git -C "$SOURCE_ABS" ls-files --others --exclude-standard)"
HAS_TRACKED=false
if [ -n "$(git -C "$SOURCE_ABS" diff --name-only HEAD)" ] || \
   [ -n "$(git -C "$SOURCE_ABS" diff --cached --name-only)" ]; then
  HAS_TRACKED=true
fi
if [ "$HAS_TRACKED" = false ] && [ -z "$UNTRACKED_FILES" ]; then
  echo "Nothing to apply."
  exit 0
fi

if [ "$HAS_TRACKED" = true ]; then
  git -C "$SOURCE_ABS" add -u -- .
  git -C "$SOURCE_ABS" commit -m "tmp: worktree apply snapshot" --no-verify --allow-empty
  TEMP_COMMIT="$(git -C "$SOURCE_ABS" rev-parse HEAD)"
  git -C "$BASE_ABS" cherry-pick --no-commit "$TEMP_COMMIT" || true
  git -C "$BASE_ABS" reset HEAD -- . >/dev/null 2>&1 || true
  git -C "$SOURCE_ABS" reset --mixed HEAD~1 >/dev/null 2>&1
fi

if [ -n "$UNTRACKED_FILES" ]; then
  echo "$UNTRACKED_FILES" | while IFS= read -r file_path; do
    [ -z "$file_path" ] && continue
    mkdir -p "$(dirname "$BASE_ABS/$file_path")"
    cp "$SOURCE_ABS/$file_path" "$BASE_ABS/$file_path"
  done
fi

git -C "$BASE_ABS" status --short
```

### If the base ref moved ahead

First understand what the branch did and whether the resolved base did the same.

Measure the branch's contribution with **three-dot**:
`git diff "$BASE_REF"...HEAD --stat` (from the merge-base). Two-dot mixes in
everything the base
gained since the merge-base: a lagging branch looks gigantic (342 files instead of
the real 16) and seems hopeless.

```bash
git merge-base "$BASE_REF" HEAD
git diff "$BASE_REF"...HEAD --stat
git log HEAD.."$BASE_REF" --oneline
git log "$(git merge-base "$BASE_REF" HEAD)..$BASE_REF" --oneline -- <files>
```

The last command is the key one: three-dot tells you what the **branch** did, but
says nothing about whether **the base did the same thing independently**. If it
touched the same files, check concretely (grep the task's target pattern across the
brief's files). A partially duplicated branch is normal: the unique part can be
valuable, the overlapping part is already stale. Decide "update or discard" from
this check, not from the size of the diff.

The exact conflict list comes from a trial merge; it is fully reversible:

```bash
git tag -f backup/<slug>-pre-update HEAD  # rollback: git reset --hard backup/<slug>-pre-update
git merge --no-commit --no-ff "$BASE_REF"
git diff --name-only --diff-filter=U      # the real conflicts
git merge --abort                         # if you decide not to continue
```

Resolve conflicts concretely, not by taking one side wholesale. Neither “the
branch is stale -> take base” nor “the branch is newer -> take branch” works when
both did the same work. Justify from surrounding code, not commit recency.

`cherry-pick` conflicts only if intermediate base commits touched the applied
files — the trigger for a rebase is file overlap, not ancestry:

```bash
git -C <worktree> diff --stat <worktree-base> <base-HEAD> -- <applied files>
```

Empty → apply as-is, no rebase needed. Non-empty → **do not leave conflict markers
in the base checkout; sync the worktree first:

1. In the worktree, commit only the needed files (a non-merge commit,
   `--no-gpg-sign`); do not include stray edits (e.g. formatter drift) —
   `git add -- "${FILES[@]}"`.
2. `git -C <worktree> -c commit.gpgsign=false rebase <base-tip>`.
3. Resolve conflicts **only with full confidence** in both sides (read both
   versions, assemble the merged file). If you are not confident —
   `rebase --abort`, do not touch the base checkout, tell the user. No conflict
   markers should
   remain in the source tree — but their absence does **not** mean the merge is
   correct (see the pitfall about duplicated insertions).
4. `<check>` in the worktree — green.
5. Apply: now `cherry-pick --no-commit` passes cleanly
   (`git merge-base --is-ancestor <base-HEAD> <worktree-HEAD>` = true).

### No-commit variant (contribution staged, HEAD = merge-base)

Night-runner branches (see `docs/ai/recipes/night-runner.md`) often hold the whole
contribution **staged, but uncommitted** (`git rev-parse HEAD` ==
`git merge-base HEAD "$BASE_REF"`). If asked not to commit, instead of commit + rebase:

1. `git stash push -m wip` -> `git merge "$BASE_REF"`.
2. `git stash pop` -> the edits land on top of the base, conflicts surface in the
   working tree.
3. Resolve conflicts only with full confidence in both sides (otherwise
   `git checkout -- .` + `git stash pop` cannot be undone — assess the risk first).
4. Run applicable checks. Result: HEAD on the base tip, contribution restored, no new
   commits.

A plain pop leaves the edits **unstaged** — if you need parity with the original
staged state, run `git add -A`.

## 3. Delete

Delete only if the path is in `git worktree list --porcelain`:

```bash
WORKTREE_ABS="$(cd "$WORKTREE_PATH" && pwd -P)"
git worktree list --porcelain | grep -Fxq "worktree $WORKTREE_ABS"
git worktree remove --force "$WORKTREE_ABS"
git worktree prune
```

`--force` removes a worktree even with uncommitted changes. Find old worktrees with
`git worktree list` and delete them the same way.

## Pitfalls (sandbox / apply / checks)

- **Edits go to `REPO_ROOT` while checks run in the worktree → false green.** The
  session is auto-started in the worktree (bash cwd = `WORKTREE_PATH`), but
  Read/Edit/Write take absolute paths from context (CLAUDE.md, earlier messages),
  and those often point at `REPO_ROOT`. Then the diff goes to the base checkout while checks
  / tests in the worktree run over the old code and "pass". The tell: you made an
  edit, but `git -C <worktree> status` does not show it. Write to paths under
  `WORKTREE_PATH` and verify in the same tree you edited.
- **Merge/rebase duplicates insertions without conflict markers.** Git merges by
  non-overlapping hunks: if both sides added the same thing in different places in a
  file, there is no conflict — **both** insertions are applied. A grep for
  `<<<<<<<` is clean, but the file is broken. Absence of markers ≠ a correct merge.
  - _Loud case_ — a duplicated declaration (`import { z } from 'zod';`,
    `const querySchema = …`): lint/typecheck fails with
    `Identifier 'X' has already been declared`. `<check>` catches it, but a marker
    grep does **not**.
  - _Silent case_ — a duplicate inside an array/object/JSX or a repeated call: the
    syntax is valid, `<check>` is green, the behavior is broken (a doubled list
    item, an overwritten field, two requests).

  After merging branches that did **the same work in parallel**, `<check>` is
  mandatory but not sufficient; read `git diff "$BASE_REF"...HEAD` yourself.
  Top-level duplicate declarations are found by this detector (it counts by
  **name**, so it also catches a `const querySchema` doubled by two **different**
  versions of the schema — the most dangerous case, where a random winner prevails):

  ```bash
  git diff --name-only "$BASE_REF"...HEAD -- '<src-glob>/*.ts' '<src-glob>/*.tsx' | while read -r f; do
    [ -f "$f" ] || continue
    awk '{ l=$0; sub(/^export +(default +)?/,"",l)
           if (l ~ /^import .*from /) { imp[l]++ }
           else if (l ~ /^(const|let|var|function|type|interface|class|enum) /) {
             n=l; sub(/^(const|let|var|function|type|interface|class|enum) +/,"",n)
             sub(/[^A-Za-z0-9_$].*/,"",n); if (n!="") d[n]++ } }
         END { for (x in imp) if (imp[x]>1) print FILENAME": "imp[x]"x "x
               for (x in d)   if (d[x]>1)   print FILENAME": "d[x]"x declaration "x }' "$f"
  done
  ```

  (Replace `<src-glob>` with your source globs, e.g. `src/**`.) Detector limits:
  top-level only (local `const`s in different functions are not duplicates) and
  single-line `import ... from` only. It does not see multi-line imports or the
  "silent case" — those are covered by `<check>` and reading the diff.

- **Partial apply**: put the file list into a bash array, `git add -- "${FILES[@]}"`.
  A `$FILES` string without an array collapses into one pathspec and stages nothing.
- **The tmp snapshot must not be a merge commit** — otherwise `cherry-pick` fails
  with `is a merge but no -m option`. Commit on top of a non-merge HEAD.
- **GPG in the sandbox** fails (`gpg: No secret key`). Commit with `--no-gpg-sign`,
  rebase with `-c commit.gpgsign=false`.
- **git outside the worktree** (apply into `REPO_ROOT`, rebase, `worktree remove`,
  `branch -D`) must run without the sandbox.
- **Installing dependencies in a fresh worktree** under the sandbox fails with
  `EPERM` on the link step — run setup without the sandbox. **Do not symlink
  a dependency directory from the base checkout**: tools may write caches inside
  it, and a write through the symlink lands in the base checkout and is blocked by the
  sandbox. Only a full, real install.
- **`CHECK_COMMAND` in the base checkout after apply** can fail under the sandbox with `EPERM` on a
  tool's temp cache while the session's working directory is still the worktree. Run
  without the sandbox, or after deleting the worktree.
- **`<check>` runs the formatter** → it may reformat unrelated files. After the
  checks, review `git status` and revert anything that is not yours
  (`git checkout -- <file>`).
- **`CHECK_COMMAND` in the base checkout scans sibling worktrees**: a formatter without a path argument
  walks the whole tree from cwd, including sibling worktree directories. A broken
  file in **someone else's** worktree fails the formatter, and a kill-others flag
  takes down the rest of the checks (non-zero exit) — it looks like your diff broke.
  If the error points at a path under a foreign worktree, check your own files
  pointwise (run the formatter/linter/typecheck/tests on your files explicitly) and
  do not fix the other worktree.
- **Lint on a detached HEAD** can yield "No files found" — run checks pointwise
  (typecheck, linter on `<files>`).
- **A review UI does not "apply" the diff** — it observes the base checkout; move
  the diff via apply first.

## Agent checklist

- [ ] The worktree is created only at the user's request.
- [ ] Apply into `REPO_ROOT` only at the user's explicit request.
- [ ] The `WORKTREE_PATH` / `REPO_ROOT` / `WORKTREE_ID` mapping is recorded.
- [ ] Setup (dependency install) done or explicitly skipped.
- [ ] All edits and checks happen in `WORKTREE_PATH`.
- [ ] A lagging branch's contribution measured with three-dot
      (`git diff "$BASE_REF"...HEAD --stat`), not two-dot; checked whether the base did the
      same work independently.
- [ ] Before apply, when the base moved ahead, the file overlap was checked
      (`git diff --stat <base> <base-HEAD> -- <files>`); rebase only on overlap,
      conflicts only with full confidence, otherwise abort + stop.
- [ ] After merge/rebase — `<check>` green **and** the diff read for duplicated
      insertions (markers may be absent).
- [ ] After apply — `git status` in `REPO_ROOT` and `<check>`, then ask about
      deleting the worktree.
