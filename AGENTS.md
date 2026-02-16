# ae

Single bash script. No dependencies beyond bash and tmux. Keep it that way.

## Philosophy

- ae is a thin wrapper around tmux — not a framework, not a platform.
- The goal is **daily productivity**, not feature completeness. If it doesn't save time on every use, it doesn't belong.
- Resist adding features. If tmux already does it, don't re-implement it.
- One file does everything. Don't split into modules or libraries.
- No build steps, no package managers, no abstractions.
- Simplicity is the feature. The entire tool must remain understandable in one sitting.

## Rules

- `ae` must remain a single bash script. No compiled languages, no runtimes.
- Config is INI-style with a simple regex parser. Don't add TOML/YAML/JSON parsing.
- No dependencies beyond bash >= 4.0, tmux, and git.
- Session state lives in `~/.ae/sessions/`. Working directories stay clean.
- No AI tool attribution in commits.
- Don't let the script grow past ~1500 lines. If it's getting long, cut, don't add.

## What ae is NOT

- Not a CI/CD pipeline. Use your existing workflow for that.
- Not a cost tracker. Agents track their own usage.
- Not a logging system. tmux already does `capture-pane` and `pipe-pane`.
- Not a git workflow tool. It does the minimum (commit + push), nothing more.
- Not a plugin framework. Bash is already the plugin system — wrap `ae` in a script if you need custom behavior.

## Structure

```
ae               — the script (~1200 lines)
test             — pure-function unit tests (bash, no deps)
test-integration — integration tests (requires tmux, git)
install          — symlink or curl|bash installer
README.md        — user docs
AGENTS.md        — this file
CLAUDE.md        — @AGENTS.md
```

## How it works

1. Parses `~/.ae/config` for agent commands and layout
2. Uses current dir (default `--local`), full copy (`--copy`), or git worktree (`--worktree`)
3. Creates tmux session with main agent (+ workers if configured)
4. Generates helpers (`send`, `spawn`) and workspace manifest
5. Launches agents with a prompt to read the manifest
6. Attaches

`ae end` commits + pushes to `ae/<session>` branch, then cleans up. `ae discard` destroys without saving.

## Config

```toml
[agents]
alias = "shell command"

[workspace]
main = alias
workers = alias, alias2    # optional, omit for single-agent start
layout = vertical
```

That's it. Don't extend the format.
