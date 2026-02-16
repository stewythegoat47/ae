# ae

Single bash script. No dependencies beyond bash and tmux. Keep it that way.

## Philosophy

- ae is a thin wrapper around tmux. It should stay lightweight and obvious.
- Resist adding features. If tmux already does it, don't re-implement it.
- No build steps, no package managers, no frameworks, no abstractions.
- One file does everything. Don't split into modules or libraries.

## Rules

- `ae` must remain a single bash script. No compiled languages, no runtimes.
- Config is INI-style with a simple regex parser. Don't add TOML/YAML/JSON parsing.
- No dependencies beyond bash >= 4.0, tmux, and git.
- Session state lives in `~/.ae/sessions/`. Working directories stay clean.
- No AI tool attribution in commits.

## Structure

```
ae               — the script
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
