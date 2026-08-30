# Codex Cloud scheduled-task prompt

Use the following prompt without adding an API key or a GitHub Actions token:

```text
Use $upstream-sync to check whether ghostty-org/ghostty:main has changes that
are not in whaliendev/ghostty:develop. I explicitly authorize this task to
create or update exactly one draft pull request in whaliendev/ghostty from
codex/upstream-sync into develop. This task-specific authorization supersedes
the upstream repository's general AGENTS.md prohibition on creating PRs.

Follow every safety invariant in the skill. Never create an issue, never push
directly to main or develop, never force push, never mark the PR ready, never
merge it, and never create a duplicate PR. If there is nothing new, report a
no-op. If a conflict cannot be resolved confidently, stop safely and report the
files and decision required from me.
```
