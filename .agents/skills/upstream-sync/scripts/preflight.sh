#!/bin/sh

set -eu

fork_remote="origin"
upstream_remote="upstream"
fork_branch="develop"
upstream_branch="main"
upstream_url="https://github.com/ghostty-org/ghostty.git"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "error: tracked files are dirty; refusing to prepare an upstream sync" >&2
  exit 2
fi

if git remote get-url "$upstream_remote" >/dev/null 2>&1; then
  actual_url="$(git remote get-url "$upstream_remote")"
  case "$actual_url" in
    https://github.com/ghostty-org/ghostty.git | git@github.com:ghostty-org/ghostty.git)
      ;;
    *)
      echo "error: upstream points to unexpected URL: $actual_url" >&2
      exit 2
      ;;
  esac
else
  git remote add "$upstream_remote" "$upstream_url"
fi

git fetch --no-tags --prune "$fork_remote" \
  "+refs/heads/$fork_branch:refs/remotes/$fork_remote/$fork_branch"
git fetch --no-tags --prune "$upstream_remote" \
  "+refs/heads/$upstream_branch:refs/remotes/$upstream_remote/$upstream_branch"

fork_ref="$fork_remote/$fork_branch"
upstream_ref="$upstream_remote/$upstream_branch"

if ! git merge-base "$fork_ref" "$upstream_ref" >/dev/null; then
  echo "error: fork and upstream do not share merge history" >&2
  exit 2
fi

upstream_sha="$(git rev-parse "$upstream_ref")"
counts="$(git rev-list --left-right --count "$fork_ref...$upstream_ref")"

echo "fork_ref=$fork_ref"
echo "upstream_ref=$upstream_ref"
echo "upstream_sha=$upstream_sha"
echo "fork_only_and_upstream_only=$counts"

if git merge-base --is-ancestor "$upstream_ref" "$fork_ref"; then
  echo "status=up-to-date"
else
  echo "status=sync-required"
fi
