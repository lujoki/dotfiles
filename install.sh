#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZED_CONFIG="$HOME/.config/zed"

mkdir -p "$ZED_CONFIG"

link() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    mv "$dest" "$dest.backup-$(date +%Y%m%d%H%M%S)"
    echo "Backed up existing $dest"
  fi

  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
}

link "$DOTFILES/zed/AGENTS.md" "$ZED_CONFIG/AGENTS.md"

if [ -f "$DOTFILES/zed/settings.json" ]; then
  link "$DOTFILES/zed/settings.json" "$ZED_CONFIG/settings.json"
else
  echo
  echo "No zed/settings.json found — it is gitignored because it holds credentials."
  echo "To start from the reference copy:"
  echo "  cp \"$DOTFILES/zed/settings.example.json\" \"$DOTFILES/zed/settings.json\""
  echo "  # fill in your credentials, then re-run ./install.sh"
fi

echo
echo "Done."
