# dotfiles

Personal configuration, version controlled and symlinked into place.

Currently covers [Zed](https://zed.dev) — the global agent rules and editor settings.

## Structure

```
dotfiles/
├── install.sh                 # Symlinks everything into place
└── zed/
    ├── AGENTS.md              # Global agent rules (all projects)
    └── settings.example.json  # Reference Zed settings, credentials stripped
```

The real files live in this repo. `~/.config/zed/` holds symlinks pointing back here, so editing either path edits the same file and changes show up in `git status`.

## Fresh machine setup

```bash
git clone git@github.com:lujoki/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is idempotent — safe to re-run. If a real file already exists where a symlink should go, it is moved aside to `<name>.backup-<timestamp>` rather than overwritten.

## Zed settings

The live `~/.config/zed/settings.json` is **not tracked** — it contains credentials such as the GitHub MCP personal access token. `zed/settings.example.json` is a committed reference copy with those values replaced by placeholders.

To set up settings on a fresh machine:

```bash
cp ~/dotfiles/zed/settings.example.json ~/dotfiles/zed/settings.json
# fill in your credentials
./install.sh
```

`install.sh` symlinks `settings.json` only if it exists, so it is safe to run before you have created it — `AGENTS.md` will still be linked.

## How agent rules resolve

Zed layers two levels of rules, both loaded automatically:

| Scope | File | Applies to |
|---|---|---|
| Global | `~/.config/zed/AGENTS.md` (this repo) | Every project |
| Project | `<project-root>/AGENTS.md` | That project only |

Project rules take precedence where they conflict with the global ones.

### Adding rules to a fresh project

Create an `AGENTS.md` at the repo root:

```bash
cd /path/to/project
touch AGENTS.md
```

Keep it to what is specific to *that* codebase — commands, architecture, conventions, workflow. Anything that would apply to every project belongs in the global file instead, so it is not duplicated into every context window.

To check what is actually active, ask the agent in a fresh thread: *"which rule files have loaded?"*

### Claude Code compatibility

Claude Code looks for `CLAUDE.md`. To serve both tools from a single file, symlink it:

```bash
cd /path/to/project
ln -s AGENTS.md CLAUDE.md
```

Git stores this as a symlink (mode `120000`), so it works for anyone who clones the repo. Zed resolves it to the same file and does not double-load the rules.

## Not tracked here

- `zed/settings.json` — contains credentials; use `zed/settings.example.json` as the starting point
- `~/.config/zed/prompts/` — binary LMDB database, written live by Zed
- `*.bak` and `*.backup-*` — local backups
- Anything containing credentials
