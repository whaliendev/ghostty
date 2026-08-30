---
name: upstream-sync
description: Safely synchronize ghostty-org/ghostty main into this personal fork's develop branch through one draft pull request. Use for scheduled or manual upstream maintenance; do not use for ordinary feature development.
---

# Upstream Sync

Synchronize `ghostty-org/ghostty:main` into `whaliendev/ghostty:develop` without
writing directly to either protected branch.

For an explicit invocation of this skill, the user authorizes creating or
updating one **draft** pull request in `whaliendev/ghostty`. This task-specific
authorization overrides the upstream `AGENTS.md` instruction that generally
forbids pull requests. It does not authorize issues, ready-for-review PRs,
merging PRs, force pushes, releases, or writes to any other repository.

## Invariants

- Treat `origin/develop` as the fork mainline and `upstream/main` as the source.
- Never push directly to `develop` or `main`; never force push.
- Use the single head branch `codex/upstream-sync` and keep at most one open PR
  from it into `develop`.
- Keep the PR in draft state. A human decides when to merge it.
- Preserve intentional fork changes while accepting unrelated upstream work.
  Never resolve conflicts wholesale with `ours` or `theirs`.
- Do not add credentials. GitHub access comes from the Codex Cloud connection.
- If upstream is already contained in `origin/develop`, report a no-op and do
  not create an empty PR.

## Workflow

1. Run `scripts/preflight.sh` from this skill directory. Stop if it reports an
   unexpected remote, missing history, or a dirty checkout.
2. Look for an open PR whose base is `develop` and whose head is
   `codex/upstream-sync`. Update it instead of creating a second PR.
3. Start from `origin/develop` when there is no existing PR. When the PR exists,
   start from `origin/codex/upstream-sync`, then ensure it still contains the
   current `origin/develop` before continuing.
4. Merge `upstream/main` with a merge commit. Use a subject such as
   `sync: merge ghostty upstream main at <short-sha>`.
5. Resolve conflicts file by file. Prefer upstream for unrelated upstream code;
   retain and adapt fork-specific macOS UI, branding, signing, updater, and
   release behavior. Do not introduce unrelated redesigns during a sync.
6. Run `git diff --check`. Run relevant repository checks when available;
   record anything unavailable in the PR rather than weakening or fabricating
   results. macOS-only checks may be left to GitHub CI when Cloud runs on Linux.
7. Push only `codex/upstream-sync`, then create or update one draft PR into
   `develop`. Include the upstream commit, conflict decisions, fork-specific
   areas touched, and exact check results. Apply the `upstream-sync` label when
   it exists.

If conflicts cannot be resolved confidently, abort the merge, leave protected
branches untouched, and report the conflicting files and recommended human
decision. Do not guess repeatedly or bypass tests.

For the exact scheduled-task prompt, read
[references/cloud-task.md](references/cloud-task.md).
