#!/usr/bin/env bash
set -euo pipefail

# Bootstraps shell, nvim, tmux, yazi, and related configs on macOS or Arch Linux.
# Idempotent: safe to re-run.

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_LINK="$HOME/.config/nvim"
YAZI_LINK="$HOME/.config/yazi"
TMUX_LINK="$HOME/.config/tmux/tmux.conf"
ALACRITTY_LINK="$HOME/.config/alacritty/alacritty.toml"
SESSIONIZER_LINK="$HOME/.local/bin/tmux-sessionizer"
ZSHRC_LINK="${ZDOTDIR:-$HOME}/.zshrc"
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
    yazi chafa \
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
    yazi chafa \
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
  warn "npm not found, skipping vtsls/vue_ls/intelephense/prettier"
fi

if has dotnet; then
  log "Installing dotnet tools"
  dotnet tool install -g csharpier 2>/dev/null || dotnet tool update -g csharpier
else
  warn "dotnet not found, skipping csharpier"
fi

install_roslyn_ls() {
  has dotnet || { warn "dotnet not found, skipping Microsoft.CodeAnalysis.LanguageServer"; return; }
  has unzip || { warn "unzip not found, skipping Microsoft.CodeAnalysis.LanguageServer"; return; }

  local rid
  case "$(uname -s)/$(uname -m)" in
    Darwin/arm64)        rid="osx-arm64" ;;
    Darwin/x86_64)       rid="osx-x64" ;;
    Linux/x86_64)        rid="linux-x64" ;;
    Linux/aarch64|Linux/arm64) rid="linux-arm64" ;;
    *) warn "unsupported platform for roslyn LSP: $(uname -s)/$(uname -m)"; return ;;
  esac

  # Pinned to a 4.14.x build (targets .NET 9). Bump when .NET 10 SDK is on the box
  # and you want Roslyn 5.x features.
  local version="4.14.0-3.26268.4"
  local install_dir="$HOME/.local/share/roslyn-ls"
  local bin="$HOME/.local/bin/Microsoft.CodeAnalysis.LanguageServer"

  if [[ -f "$install_dir/.version" ]] && [[ "$(<"$install_dir/.version")" == "$version" ]] && [[ -x "$bin" ]]; then
    log "Microsoft.CodeAnalysis.LanguageServer $version already installed"
    return
  fi

  log "Installing Microsoft.CodeAnalysis.LanguageServer $version ($rid)"
  local pkg_url="https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/flat2/microsoft.codeanalysis.languageserver.${rid}/${version}/microsoft.codeanalysis.languageserver.${rid}.${version}.nupkg"
  local tmpdir
  tmpdir=$(mktemp -d) || { warn "failed to create tmpdir"; return; }

  local status=0
  (
    set -e
    curl -fsSL -o "$tmpdir/lsp.nupkg" "$pkg_url"
    unzip -q "$tmpdir/lsp.nupkg" -d "$tmpdir/pkg"
    local src="$tmpdir/pkg/content/LanguageServer/$rid"
    [[ -f "$src/Microsoft.CodeAnalysis.LanguageServer.dll" ]]
    rm -rf "$install_dir"
    mkdir -p "$install_dir"
    cp -R "$src/." "$install_dir/"
    echo "$version" > "$install_dir/.version"
  ) || status=$?
  rm -rf "$tmpdir"
  if [[ $status -ne 0 ]]; then
    warn "Microsoft.CodeAnalysis.LanguageServer install failed (download/extract/layout)"
    return
  fi

  mkdir -p "$HOME/.local/bin"
  cat > "$bin" <<EOF
#!/bin/sh
exec dotnet "$install_dir/Microsoft.CodeAnalysis.LanguageServer.dll" "\$@"
EOF
  chmod +x "$bin"
}

install_roslyn_ls

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

symlink_config "$DOTFILES/zsh/zshrc" "$ZSHRC_LINK" "zshrc"
symlink_config "$DOTFILES/nvim" "$NVIM_LINK" "nvim"
symlink_config "$DOTFILES/yazi" "$YAZI_LINK" "yazi"
symlink_config "$DOTFILES/clangd/config.yaml" "$CLANGD_LINK" "clangd config"
symlink_config "$DOTFILES/tmux/tmux.conf" "$TMUX_LINK" "tmux"
symlink_config "$DOTFILES/alacritty/alacritty.toml" "$ALACRITTY_LINK" "alacritty"
symlink_config "$DOTFILES/tmux/tmux-sessionizer" "$SESSIONIZER_LINK" "tmux-sessionizer"

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
