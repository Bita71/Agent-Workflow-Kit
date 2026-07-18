# apply-worktree

Apply a worktree's diff into the base checkout — only when the user explicitly
asks to transfer changes.

Follow the **Apply** section of `docs/ai/recipes/git-worktree.md` exactly.
Transfer tracked changes via a temporary commit + `cherry-pick --no-commit` and
untracked files by copy; leave the result unstaged in the base checkout for the
user to review and commit. After apply, ask whether to delete the worktree.
