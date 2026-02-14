# ae - agentic engineering

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-%3E%3D4.0-green.svg)](https://www.gnu.org/software/bash/)
[![tmux](https://img.shields.io/badge/requires-tmux-1BB91F.svg)](https://github.com/tmux/tmux)
[![Install](https://img.shields.io/badge/install-curl%20%7C%20bash-orange.svg)](#install)

**ae** -- run multiple AI coding agents side-by-side in tmux with shared awareness.

```
+---------------------------+---------------------------+
|  cc (claude code)         |  cx (codex)               |
|                           |                           |
|  > Reading workspace...   |  > Reading workspace...   |
|  I see cx is in pane %1.  |  I see cc is in pane %0.  |
|  I can send it messages   |  Waiting for tasks from   |
|  via tmux send-keys.      |  the main agent.          |
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

That's it. First run creates a tmux session with your configured agents. Run `ae` again from the same directory to reattach.

Detach with `Ctrl+b d`. Agents keep running in the background.

## Commands

```
ae                  Start or reattach default session for current directory
ae <name>           Start or reattach a named session
ae list             Show all ae sessions
ae kill <name>      Kill a specific session
ae kill all         Kill all ae sessions
ae help         Show usage
```

## Config

`~/.ae/config` is auto-created on first run:

```toml
[agents]
cc = "claude --permission-mode bypassPermissions --model claude-opus-4-6"
cx = "codex --yolo -m gpt-5.3-codex -c model_reasoning_effort=high"
oc = "opencode"

[workspace]
main = cc
workers = cx
layout = vertical
```

### Agents

Define any number of agents as aliases. The value is the full shell command to launch the agent.

### Workspace

| Key       | Description                                           | Default    |
|-----------|-------------------------------------------------------|------------|
| `main`    | Agent alias for the primary pane                      | `cc`       |
| `workers` | Comma-separated agent aliases for additional panes    | `cx`       |
| `layout`  | `vertical` (side-by-side) or `horizontal` (stacked)   | `vertical` |

### Examples

Two workers (3 panes):
```toml
workers = cx, oc
```

Stacked layout:
```toml
layout = horizontal
```

## How agents communicate

On session creation, `ae` writes `.ae/workspace.md` in the project directory:

```markdown
# ae workspace

Session: ae-projects-my-app
Directory: /home/user/projects/my-app

## Agents

| Alias | Tool        | Role   | tmux target |
|-------|-------------|--------|-------------|
| cc    | claude code | main   | %0          |
| cx    | codex       | worker | %1          |
```

Each agent starts with a prompt to read this file. From there, any agent can:

**Send a message to another agent:**
```bash
tmux send-keys -t "%1" "Review the changes in src/auth.ts" C-m
```

**Check what another agent is doing:**
```bash
tmux capture-pane -t "%1" -p | tail -20
```

The human sees all panes and can type in any of them.

## Session management

- `ae` with no arguments creates a default session named after the directory
- `ae self-learning` creates a session named `self-learning` -- you pick the name
- Multiple named sessions can run in the same directory
- `ae <name>` from anywhere reattaches if the session exists
- Sessions survive terminal close (tmux runs in background)
- Sessions do **not** survive reboot -- just run `ae` again
- `ae list` shows all sessions with their directories

## How it works

1. Parses `~/.ae/config`
2. Creates a tmux session with one pane per agent
3. Captures actual tmux pane IDs (works regardless of `base-index` settings)
4. Writes `.ae/workspace.md` with the agent manifest
5. Launches each agent with an initial prompt pointing to the manifest
6. Attaches you to the session

## Requirements

- [tmux](https://github.com/tmux/tmux)
- At least one AI coding agent ([Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Codex](https://github.com/openai/codex), [OpenCode](https://github.com/opencode-ai/opencode), or any CLI tool)

## License

MIT
