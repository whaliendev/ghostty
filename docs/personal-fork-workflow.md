# Personal fork workflow

This fork uses `develop` as its integration and release mainline while following
`ghostty-org/ghostty:main` through reviewed pull requests.

## Branch model

- `upstream/main`: read-only official Ghostty history.
- `origin/develop`: protected personal mainline and base for every personal PR.
- `feature/*` or `fix/*`: normal personal development branches.
- `codex/upstream-sync`: the single reusable Codex Cloud upstream-sync branch.

Neither people nor automation push directly to `develop`. Personal changes and
upstream syncs enter it through pull requests. Upstream sync PRs always remain
draft until manually reviewed and merged.

## One-time Codex Cloud setup

1. Connect GitHub to Codex and grant write access to `whaliendev/ghostty`.
2. In Codex Cloud settings, create an environment for that repository with
   `develop` as its base branch.
3. Set the environment setup script to:

   ```sh
   bash .agents/skills/upstream-sync/scripts/preflight.sh
   ```

   Setup-script internet access is sufficient. No `OPENAI_API_KEY`, personal
   access token, repository secret, or GitHub Actions workflow is required.
4. Create a scheduled Codex task using the prompt in
   `.agents/skills/upstream-sync/references/cloud-task.md`. Run it daily at
   09:30 Asia/Shanghai; a no-op run is expected when upstream has not changed.

The scheduled task may create or update only the draft sync PR. It cannot merge
the PR or write protected branches.

## Personal development

Start work from the latest `develop`, use a short-lived branch, and open a PR
back into `develop`. Rebase the feature branch on `develop` before review when
practical. Avoid building long-lived work directly on the sync branch.

## Reviewing an upstream sync

Pay special attention to conflicts in the macOS window UI, branding, bundle
identity, signing, updater, entitlements, and release automation. Confirm the
PR body lists the upstream commit and exact checks. Let normal GitHub CI finish,
then build and smoke-test the macOS app locally before merging substantial
updates.

If the Cloud task stops on a conflict, resolve it on `codex/upstream-sync`, run
the same checks, and leave the PR draft until the fork behavior is verified.
