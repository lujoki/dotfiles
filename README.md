# dotfiles

Personal configuration, versioned so it survives a new machine.

```
agents/
├── AGENTS.md   # standing agent instructions, applied to every project
└── CLAUDE.md   # symlink -> AGENTS.md, so Claude Code and other tooling agree
```

## Install

```bash
./install.sh
```

Symlinks `agents/AGENTS.md` into the global instruction file each agent tool
reads, so every one of them works from the same rules:

| Tool | Destination |
|---|---|
| Claude Code | `~/.claude/CLAUDE.md` |
| Zed | `~/.config/zed/AGENTS.md` |
| Codex CLI | `~/.codex/AGENTS.md` |
| Gemini CLI | `~/.gemini/GEMINI.md` |
| Qwen Code | `~/.qwen/QWEN.md` |
| opencode | `~/.config/opencode/AGENTS.md` |
| Windsurf | `~/.codeium/windsurf/memories/global_rules.md` |
| Cline | `~/Documents/Cline/Rules/AGENTS.md` |

Claude Code and Zed are linked unconditionally. The rest are linked only if the
tool's config directory already exists, so nothing leaves a stray directory
behind for something that isn't installed; `--all` links them anyway. `--dry-run`
prints the plan and changes nothing. Re-running is safe: a link already pointing
at the right file is left alone, and a real file is backed up with a timestamp
before being replaced.

Cursor, VS Code Copilot, Ollama and DeepSeek have no symlinkable global
instruction file. The script prints what to do about each at the end.

The directory is named `agents/` rather than after any one provider, since every
tool above reads the same file under a different name.

## agents/AGENTS.md

House rules: how I want work reported, validated, handed off and cleaned up, and
how Linear tickets are handled on any board.

Not in here: anything true of one project only, such as its repos, ports, paths,
conventions, domain model, release process, Linear board or label set. Those live
in that project's own `AGENTS.md`, which sits on top of this file and **wins** on
any disagreement.
