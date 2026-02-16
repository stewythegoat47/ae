# ae - agentic engineering

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-%3E%3D4.0-green.svg)](https://www.gnu.org/software/bash/)
[![tmux](https://img.shields.io/badge/requires-tmux-1BB91F.svg)](https://github.com/tmux/tmux)
[![Install](https://img.shields.io/badge/install-curl%20%7C%20bash-orange.svg)](#install)

**ae** -- run AI coding agents in tmux with shared awareness. Start with one, spawn more on demand.

```
+---------------------------+---------------------------+
|  claude (claude code)     |  codex                    |
|                           |                           |
|  > Reading workspace...   |  > Spawned into session.  |
|  I'll spawn codex to      |  Reading workspace.md...  |
|  review my changes.       |  I see claude in pane %0. |
+---------------------------+---------------------------+
```

Agents know about each other. They can send messages, peek at output, and coordinate -- all through tmux.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/clemens33/ae/main/install | bash
```

Or clone manually:

```bash
git clone https://github.com/clemens33/ae.git ~/.local/share/ae
~/.local/share/ae/install
```

Both methods symlink `ae` to `~/.local/bin/ae`. Make sure `~/.local/bin` is on your `PATH`.

## Quick start

```bash
cd ~/projects/my-app
ae
```

That's it. First run creates a tmux session with your main agent. Spawn more agents on demand from within the session.

Detach with `Ctrl+b d`. Agents keep running in the background.

## Commands

```
ae                     Start or reattach default session (local)
ae <name>              Start or reattach a named session
ae --local [name]      Start session in current directory (default)
ae --copy [name]       Start session with full copy (includes untracked files)
ae --worktree [name]   Start session with git worktree (tracked files only)
ae list                List all ae sessions
ae end <name>          End session: commit, push to ae/<name> branch, clean up
ae discard <name>      Discard session without saving (destroy worktree/copy)
ae help                Show usage
```

## Spawning agents

By default, `ae` starts with just the main agent. Spawn more on demand:

```bash
~/.ae/sessions/<session>/spawn codex                          # spawn with default prompt
~/.ae/sessions/<session>/spawn codex "Review changes in src/"  # spawn with custom prompt
```

The spawn helper:
1. Looks up the agent command from `~/.ae/config`
2. Opens a new tmux pane
3. Updates `workspace.md` so all agents see each other
4. Launches the agent with the prompt

Spawned agents are ephemeral -- they exist only while the tmux session is alive. On resume after reboot, only config-defined agents (main + optional workers) are relaunched.

## Modes

| Mode | Flag | Description |
|------|------|-------------|
| **local** | `--local` | Work directly in the current directory. No copy, no overhead. Default. |
| **copy** | `--copy` | Full `cp -a` copy. Includes untracked files (node_modules, .venv, etc.). |
| **worktree** | `--worktree` | Git worktree (detached HEAD). Fast, shares `.git`, tracked files only. |

All sessions persist across reboots. Run `ae <name>` again to resume agents with their previous conversation context.

```bash
ae --copy my-rework       # full copy for heavy dependency work
ae --local quick-fix      # no copy, just orchestrate agents here
```

Set the default in config:
```toml
[workspace]
copy = full    # or "local" (default) or "git"
```

CLI flags always override the config.

## Config

`~/.ae/config` is auto-created on first run:

```toml
[agents]
claude = "claude --permission-mode bypassPermissions --model claude-opus-4-6"
codex = "codex --yolo -m gpt-5.3-codex -c model_reasoning_effort=high"
opencode = "opencode"

[workspace]
main = claude
layout = vertical
```

### Agents

Define any number of agents as aliases. The value is the full shell command to launch the agent.

### Workspace

| Key       | Description                                                | Default    |
|-----------|------------------------------------------------------------|------------|
| `main`    | Agent alias for the primary pane                           | `claude`   |
| `workers` | Comma-separated aliases for agents launched at startup     | *(empty)*  |
| `layout`  | `vertical` (side-by-side) or `horizontal` (stacked)        | `vertical` |
| `copy`    | `local`, `full` (cp -a), or `git` (worktree)              | `local`    |

### Examples

Pre-launch workers at startup (optional):
```toml
workers = codex, opencode
```

Stacked layout:
```toml
layout = horizontal
```

## How agents communicate

On session creation, `ae` writes `~/.ae/sessions/<session>/workspace.md`:

```markdown
# ae workspace

Session: ae-projects-my-app-abc123
Directory: /home/user/.ae/worktrees/ae-projects-my-app-abc123
Mode: git

## Agents

| Alias  | Tool        | Role   | tmux target |
|--------|-------------|--------|-------------|
| claude | claude code | main   | %0          |
| codex  | codex       | worker | %1          |

## Spawn

Add another agent to this workspace:
~/.ae/sessions/<session>/spawn <alias> [prompt]
```

Session state (helpers, manifest, metadata) lives in `~/.ae/sessions/` — working directories stay clean.

Each agent starts with a prompt to read this file. From there, any agent can:

**Send a message to another agent:**
```bash
~/.ae/sessions/<session>/send "%1" "Review the changes in src/auth.ts"
```

**Spawn another agent:**
```bash
~/.ae/sessions/<session>/spawn codex "Review these changes"
```

**Check what another agent is doing:**
```bash
tmux capture-pane -t "%1" -p | tail -20
```

The human sees all panes and can type in any of them.

## Ending sessions

When you're done, `ae end` commits any uncommitted work, pushes it to a branch, and cleans up:

```bash
ae end my-feature        # commit + push to origin/ae/my-feature, then remove worktree
ae end all               # end all sessions
```

What `ae end` does (worktree/copy mode with git):
1. `git add -A && git commit` if there are uncommitted changes
2. `git push -u origin HEAD:refs/heads/ae/<session>` if there are unpushed commits
3. Kill the tmux session and remove the worktree/copy

If the push fails, the session is **preserved** -- nothing is deleted. Fix the issue and retry.

For local mode, `ae end` just kills the tmux session (files are already in your project directory).

To throw away a session without saving:

```bash
ae discard my-experiment   # destroy without commit/push
ae discard all
```

## Session management

- `ae` with no arguments creates a default session named after the directory
- `ae self-learning` creates a session named `self-learning` -- you pick the name
- Multiple named sessions can run in the same directory
- `ae <name>` from anywhere reattaches if the session exists
- Sessions survive terminal close (tmux runs in background)
- **All sessions survive reboot** -- run `ae <name>` again to resume agents with their previous conversation context
- Agents with session support (Claude Code) resume exact conversations; others start fresh
- On resume, all agents are relaunched (main, workers, and runtime-spawned agents)
- `ae list` shows running and stopped sessions with agent health (`2/2` = all healthy, `1/2!` = one crashed)
- `ae end <name>` preserves work (commit + push) then cleans up
- `ae discard <name>` destroys the session without saving

## How it works

1. Validates `~/.ae/config`
2. Creates a git worktree, full copy, or uses the current directory (local mode)
3. Creates a tmux session with the main agent (+ workers if configured)
4. Generates helper scripts and workspace manifest in `~/.ae/sessions/`
5. Launches agents with a prompt pointing to the manifest
6. Attaches you to the session

In worktree/copy mode, agents work on a separate directory. When done, `ae end` commits and pushes the work, then cleans up. After a reboot, run `ae <name>` again to resume. In local mode, agents work directly on the original files.

## Requirements

- [tmux](https://github.com/tmux/tmux)
- [git](https://git-scm.com/) (for worktree mode and `ae end` push; not needed with `--copy --local`)
- At least one AI coding agent ([Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Codex](https://github.com/openai/codex), [OpenCode](https://github.com/opencode-ai/opencode), or any CLI tool)

## Environment variables

| Variable | Description |
|----------|-------------|
| `AE_TMUX_SERVER` | Use an isolated tmux server (e.g., `AE_TMUX_SERVER=work ae foo`). Useful for separating ae from personal tmux sessions. |

## License

MIT
