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
- `.ae/` in project dirs is session-local state -- always gitignored.
- No AI tool attribution in commits.

## Structure

```
ae        — the script
install   — symlink or curl|bash installer
README.md — user docs
AGENTS.md — this file
CLAUDE.md — @AGENTS.md
```

## How it works

1. Parses `~/.ae/config` for agent commands and layout
2. Creates a git worktree (default), full copy (`--copy`), or uses current dir (`--local`)
3. Writes `.ae/workspace.md` so agents know about each other
4. Launches agents with a prompt to read the manifest
5. Attaches

## Config

```toml
[agents]
alias = "shell command"

[workspace]
main = alias
workers = alias, alias2
layout = vertical
```

That's it. Don't extend the format.
