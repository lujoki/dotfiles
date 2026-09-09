#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS="$DOTFILES/agents/AGENTS.md"

DRY_RUN=0
ALL=0

usage() {
  cat <<USAGE
Usage: ./install.sh [--dry-run] [--all]

Symlinks agents/AGENTS.md into the global instruction file each agent tool reads.

  --dry-run   Print what would happen, change nothing
  --all       Also link tools that are not installed yet, creating their
              config directories. Default is to skip anything absent.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --all) ALL=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

[ -f "$AGENTS" ] || { echo "Missing $AGENTS" >&2; exit 1; }

linked=0
skipped=0

link() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  already linked  $dest"
    linked=$((linked + 1))
    return
  fi

  if [ "$DRY_RUN" = 1 ]; then
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      echo "  would replace   $dest -> $src"
    else
      echo "  would link      $dest -> $src"
    fi
    linked=$((linked + 1))
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    mv "$dest" "$dest.backup-$(date +%Y%m%d%H%M%S)"
    echo "  backed up       $dest"
  fi

  ln -s "$src" "$dest"
  echo "  linked          $dest -> $src"
  linked=$((linked + 1))
}

# link_if <tool label> <config dir to test> <destination file>
#
# Links only when the tool's config directory already exists, so a path that
# is wrong for a tool never leaves a stray directory behind. --all overrides.
link_if() {
  local label="$1" probe="$2" dest="$3"

  echo "$label"
  if [ -d "$probe" ] || [ "$ALL" = 1 ]; then
    link "$AGENTS" "$dest"
  else
    echo "  skipped         $probe not found (--all to link anyway)"
    skipped=$((skipped + 1))
  fi
}

echo "Source: $AGENTS"
echo

# Always linked: the two I actually use.
echo "Claude Code"
link "$AGENTS" "$HOME/.claude/CLAUDE.md"

echo "Zed"
link "$AGENTS" "$HOME/.config/zed/AGENTS.md"

# Linked when the tool is installed. Each reads its own filename.
link_if "Codex CLI"   "$HOME/.codex"           "$HOME/.codex/AGENTS.md"
link_if "Gemini CLI"  "$HOME/.gemini"          "$HOME/.gemini/GEMINI.md"
link_if "Qwen Code"   "$HOME/.qwen"            "$HOME/.qwen/QWEN.md"
link_if "opencode"    "$HOME/.config/opencode" "$HOME/.config/opencode/AGENTS.md"
link_if "Windsurf"    "$HOME/.codeium/windsurf" \
        "$HOME/.codeium/windsurf/memories/global_rules.md"
link_if "Cline"       "$HOME/Documents/Cline"  "$HOME/Documents/Cline/Rules/AGENTS.md"

# Tool-specific config that is not agent instructions. Only if this repo
# carries it, since settings files tend to hold credentials and stay ignored.
if [ -d "$DOTFILES/zed" ]; then
  echo "Zed settings"
  if [ -f "$DOTFILES/zed/settings.json" ]; then
    link "$DOTFILES/zed/settings.json" "$HOME/.config/zed/settings.json"
  else
    echo "  skipped         no zed/settings.json (gitignored, holds credentials)"
    if [ -f "$DOTFILES/zed/settings.example.json" ]; then
      echo "                  cp zed/settings.example.json zed/settings.json, fill it in, re-run"
    fi
    skipped=$((skipped + 1))
  fi
fi

echo
echo "$linked linked, $skipped skipped."

cat <<'MANUAL'

Not linkable, do these by hand once:

  Cursor          Global rules live in Settings > Rules ("User Rules"), stored
                  in Cursor's own state rather than a file. Paste the contents
                  of agents/AGENTS.md in. Per-project, Cursor reads a root
                  AGENTS.md on its own.
  VS Code Copilot User-level instructions are profile prompt files needing
                  `applyTo` frontmatter, so a plain symlink of this file will
                  not apply. Point a repo at it with .github/copilot-instructions.md
                  instead, or enable chat.useAgentsMdFile and keep a root AGENTS.md.
  DeepSeek        No first-party CLI agent with a global instruction path. In a
                  third-party harness, point that harness at this file.
MANUAL
