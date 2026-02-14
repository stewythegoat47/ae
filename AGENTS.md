# ae

Single bash script (`ae`) that launches tmux-based multi-agent workspaces. Config at `~/.ae/config`.

## Structure

```
ae        — main script (bash, ~270 lines)
install   — installer (local symlink or curl|bash clone)
README.md — user docs
```

## How it works

1. Parses INI-style config (`~/.ae/config`) for agent commands and workspace layout
2. Creates a tmux session named after `$PWD` with a hash suffix for uniqueness
3. Captures real tmux pane IDs (not index-based — works with any `base-index`)
4. Writes `.ae/workspace.md` manifest in the project directory
5. Launches each agent with an initial prompt to read the manifest
6. Agents discover each other's pane IDs and communicate via `tmux send-keys`

## Config format

```toml
[agents]
alias = "full shell command"

[workspace]
main = alias        # primary pane
workers = alias     # comma-separated for multiple
layout = vertical   # vertical (side-by-side) or horizontal (stacked)
```

## Key design decisions

- Session names: `ae-<path>-<hash>` where hash is 6-char md5 of `$PWD` to avoid path-flattening collisions
- tmux options are session-scoped (mouse, 50k scrollback, pane border labels) — doesn't affect other tmux usage
- `CLAUDECODE` env var is unset in the tmux session so Claude Code doesn't refuse to start
- Install script detects local clone vs curl pipe via `BASH_SOURCE[0]`

## Rules

- Keep it a single file. No dependencies beyond bash and tmux.
- Config is INI-style, not TOML — the parser is intentionally simple. Don't add nested sections or arrays.
- `#` inside quoted values is preserved. Comments only stripped on unquoted values.
- `.ae/` directories in project repos should be gitignored — they contain session-local state.
- No AI tool attribution in commits.
