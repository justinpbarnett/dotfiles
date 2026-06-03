#!/usr/bin/env bash
set -euo pipefail

# Removes the symlinks created by install.sh.
# Does NOT uninstall brew/pacman packages.
# Idempotent: safe to re-run.

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_LINK="$HOME/.config/nvim"
YAZI_LINK="$HOME/.config/yazi"
ZSHRC_LINK="${ZDOTDIR:-$HOME}/.zshrc"
TMUX_LINK="$HOME/.config/tmux/tmux.conf"
ALACRITTY_LINK="$HOME/.config/alacritty/alacritty.toml"
case "$(uname -s)" in
Darwin) CLANGD_LINK="$HOME/Library/Preferences/clangd/config.yaml" ;;
*) CLANGD_LINK="${XDG_CONFIG_HOME:-$HOME/.config}/clangd/config.yaml" ;;
esac

log() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }

unlink_config() {
  local src="$1" dst="$2" label="$3"
  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      log "Removing $label symlink: $dst"
      rm "$dst"
    else
      warn "$dst is a symlink but points elsewhere: $current"
      warn "Leaving it alone."
    fi
  elif [[ -e "$dst" ]]; then
    warn "$dst exists and is not a symlink. Leaving it alone."
  else
    log "$label already absent"
  fi
}

unlink_config "$DOTFILES/zsh/zshrc" "$ZSHRC_LINK" "zshrc"
unlink_config "$DOTFILES/nvim" "$NVIM_LINK" "nvim"
unlink_config "$DOTFILES/yazi" "$YAZI_LINK" "yazi"
unlink_config "$DOTFILES/clangd/config.yaml" "$CLANGD_LINK" "clangd config"
unlink_config "$DOTFILES/tmux/tmux.conf" "$TMUX_LINK" "tmux"
unlink_config "$DOTFILES/alacritty/alacritty.toml" "$ALACRITTY_LINK" "alacritty"

cat <<'EOF'

Done. Symlinks removed.

Packages installed by install.sh were left alone. Remove them manually if
desired (brew uninstall ..., sudo pacman -Rns ...).
EOF
