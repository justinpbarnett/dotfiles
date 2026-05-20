#!/usr/bin/env bash
set -euo pipefail

# Bootstraps the nvim and tmux configs on a fresh macOS or Arch Linux machine.
# Idempotent: safe to re-run.

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_LINK="$HOME/.config/nvim"
TMUX_LINK="$HOME/.config/tmux/tmux.conf"
ALACRITTY_LINK="$HOME/.config/alacritty/alacritty.toml"
case "$(uname -s)" in
Darwin) CLANGD_LINK="$HOME/Library/Preferences/clangd/config.yaml" ;;
*) CLANGD_LINK="${XDG_CONFIG_HOME:-$HOME/.config}/clangd/config.yaml" ;;
esac

log() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
err() {
  printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2
  exit 1
}
has() { command -v "$1" >/dev/null 2>&1; }

OS=""
case "$(uname -s)" in
Darwin) OS=mac ;;
Linux)
  if [[ -f /etc/arch-release ]]; then
    OS=arch
  else
    err "Unsupported Linux distro. Only Arch is set up. Edit install.sh to add support."
  fi
  ;;
*) err "Unsupported OS: $(uname -s)" ;;
esac

log "Detected OS: $OS"

install_mac() {
  has brew || err "Homebrew not found. Install it from https://brew.sh first."
  log "Installing packages via brew"
  brew install \
    neovim \
    tree-sitter-cli \
    tmux \
    fzf bat ripgrep fd \
    lazygit \
    lua-language-server stylua \
    basedpyright ruff \
    node \
    composer \
    llvm \
    shellcheck shfmt
  has dotnet || brew install --cask dotnet-sdk
  has alacritty || brew install --cask alacritty
}

install_arch() {
  log "Installing packages via pacman"
  sudo pacman -S --needed --noconfirm \
    neovim \
    tree-sitter-cli \
    tmux \
    fzf bat ripgrep fd \
    lazygit \
    lua-language-server \
    ruff \
    nodejs npm \
    composer \
    clang \
    dotnet-sdk \
    shellcheck shfmt \
    alacritty

  local helper=""
  if has paru; then
    helper=paru
  elif has yay; then
    helper=yay
  fi

  if [[ -n "$helper" ]]; then
    log "Installing AUR packages via $helper"
    "$helper" -S --needed --noconfirm stylua basedpyright
  else
    warn "No AUR helper (yay/paru) found."
    warn "Install stylua and basedpyright manually, or install an AUR helper and re-run."
  fi
}

case "$OS" in
mac) install_mac ;;
arch) install_arch ;;
esac

if has npm; then
  log "Installing npm globals"
  npm install -g \
    @vtsls/language-server \
    @vue/language-server \
    intelephense \
    bash-language-server \
    prettier
else
  warn "npm not found, skipping vtsls/volar/intelephense/prettier"
fi

if has dotnet; then
  log "Installing dotnet tools"
  dotnet tool install -g csharpier 2>/dev/null || dotnet tool update -g csharpier
else
  warn "dotnet not found, skipping csharpier"
fi

if has composer; then
  log "Installing composer globals"
  composer global require laravel/pint
else
  warn "composer not found, skipping laravel/pint"
fi

symlink_config() {
  local src="$1" dst="$2" label="$3"
  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      log "$label already symlinked correctly"
    else
      warn "$dst points elsewhere: $current"
      warn "Remove or fix it, then re-run."
    fi
  elif [[ -e "$dst" ]]; then
    warn "$dst exists and is not a symlink."
    warn "Move it aside (mv $dst $dst.bak), then re-run."
  else
    log "Symlinking $src -> $dst"
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
  fi
}

symlink_config "$DOTFILES/nvim" "$NVIM_LINK" "nvim"
symlink_config "$DOTFILES/clangd/config.yaml" "$CLANGD_LINK" "clangd config"
symlink_config "$DOTFILES/tmux/tmux.conf" "$TMUX_LINK" "tmux"
symlink_config "$DOTFILES/alacritty/alacritty.toml" "$ALACRITTY_LINK" "alacritty"

cat <<'EOF'

Done.

Next steps:
  1. Ensure PATH includes:
       ~/.dotnet/tools                                 (csharpier)
       $(composer global config bin-dir --absolute)    (pint)
  2. Open nvim. lazy.nvim bootstraps and installs all plugins on first run.
  3. Authenticate Supermaven Pro inside nvim:
       :SupermavenUsePro
EOF
