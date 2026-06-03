# macOS-only shell setup (Homebrew paths, nvm, Mono, Herd).

if command -v brew &>/dev/null; then
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  _brew_nvm="$(brew --prefix nvm 2>/dev/null)" || _brew_nvm=""
  if [[ -n "$_brew_nvm" && -s "$_brew_nvm/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    . "$_brew_nvm/nvm.sh"
    [[ -s "$_brew_nvm/etc/bash_completion.d/nvm" ]] && . "$_brew_nvm/etc/bash_completion.d/nvm"
  fi
  unset _brew_nvm

  _brew_prefix="$(brew --prefix 2>/dev/null)" || _brew_prefix=""
  [[ -n "$_brew_prefix" ]] && export MONO_GAC_PREFIX="$_brew_prefix"
  unset _brew_prefix
fi

_herd_bin="$HOME/.config/herd-lite/bin"
if [[ -d "$_herd_bin" ]]; then
  path_prepend "$_herd_bin"
  export PHP_INI_SCAN_DIR="${_herd_bin}${PHP_INI_SCAN_DIR:+:$PHP_INI_SCAN_DIR}"
fi
unset _herd_bin
export PATH