# ae - agentic engineering

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-%3E%3D4.0-green.svg)](https://www.gnu.org/software/bash/)
[![tmux](https://img.shields.io/badge/requires-tmux-1BB91F.svg)](https://github.com/tmux/tmux)
[![Install](https://img.shields.io/badge/install-curl%20%7C%20bash-orange.svg)](#install)

**ae** runs AI coding agents side-by-side in tmux. They know about each other, communicate by name, and survive reboots. One bash script, zero dependencies.

Works with [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Codex](https://github.com/openai/codex), [OpenCode](https://github.com/opencode-ai/opencode), or any CLI tool.

## Why ae

- **One command** -- `ae` starts a session, `ae` reattaches. That's the whole workflow.
- **Agents talk to each other** -- each agent gets workspace context injected into its system prompt. They send messages by name, spawn new agents, and coordinate without manual wiring.
- **Everything survives reboots** -- sessions, spawned agents, conversation history. Pick up exactly where you left off.
- **Nothing touches your repo** -- session state lives in `~/.ae/sessions/`. Your working directory stays clean.
- **Single bash script** -- no frameworks, no runtimes, no abstractions. Just bash, tmux, and git.

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

First run creates `~/.ae/config` with sensible defaults and launches your main agent in tmux. Detach with `Ctrl+b d` -- agents keep running in the background.

## What you can do

**Start a session and let agents collaborate:**
```bash
ae my-feature                  # named session
ae                             # default session (named after directory)
```

**Spawn agents from within a session (or let your main agent do it):**
```bash
spawn codex:reviewer "Review the changes in src/"
spawn claude:pair-programmer "Help me refactor the auth module"
```

Agents pick descriptive names and address each other directly:
```bash
send "claude:lead" "I found a bug in auth.ts, check line 42"
send "codex:reviewer" "Looks good, merge it"
```

**Come back after a reboot:**
```bash
ae my-feature                  # all agents resume with their conversation history
```

**Check on agents without attaching:**
```bash
ae status my-feature           # see recent output from all agents
ae list                        # all sessions with agent health (2/2 or 1/2!)
```

**Finish up:**
```bash
ae end my-feature              # commit + push to ae/my-feature branch, clean up
ae discard my-experiment       # throw away without saving
```

## Config

`~/.ae/config` is auto-created on first run. Per-project overrides go in `.ae/config` in your project directory.

```toml
[agents]
claude = "claude --permission-mode bypassPermissions --model claude-opus-4-6"
codex = "codex --yolo -m gpt-5.3-codex -c model_reasoning_effort=high"
opencode = "opencode"

[workspace]
main = claude:lead
layout = vertical
```

**`[agents]`** -- register any CLI tool as an agent alias. The value is the shell command to launch it.

**`[workspace]`** -- control the session layout:

| Key       | Description                                          | Default       |
|-----------|------------------------------------------------------|---------------|
| `main`    | `alias:name` for the primary agent                   | `claude:lead` |
| `workers` | Comma-separated agents launched at startup           | *(empty)*     |
| `layout`  | `vertical` (side-by-side) or `horizontal` (stacked)  | `vertical`    |
| `copy`    | `local`, `full` (cp -a), or `git` (worktree)         | `local`       |

Names show in pane borders and are how agents address each other.

**Pre-launch multiple agents:**
```toml
workers = codex:reviewer, opencode:tester
```

## Commands

```
ae [name]              Start or reattach a session
ae list                List all sessions with agent health
ae status [name]       Show agent output without attaching
ae stop [name]         Pause session, keep state for later
ae end [name]          Commit, push to ae/<name> branch, clean up
ae discard [name]      Destroy session without saving
```

When run inside an ae session, `stop`, `end`, `discard`, and `status` detect the current session automatically.

## How it works

1. Reads `~/.ae/config` for agent commands and layout
2. Creates a tmux session with the main agent (+ workers if configured)
3. Injects workspace context into each agent's system prompt
4. Generates helper scripts (`send`, `spawn`) in `~/.ae/sessions/`
5. Attaches you to the session

Agents communicate by name through the `send` helper. They can spawn new agents on demand. Everything persists in `~/.ae/sessions/` -- your repo stays clean, and all agents resume after a reboot.

## Requirements

- [tmux](https://github.com/tmux/tmux)
- [git](https://git-scm.com/)
- At least one AI coding agent ([Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Codex](https://github.com/openai/codex), [OpenCode](https://github.com/opencode-ai/opencode), or any CLI tool)

## License

MIT
