# Linux (Arch) shell setup.

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"
fi

# Composer global bin (when install.sh ran composer global require)
if command -v composer &>/dev/null; then
  _composer_bin="$(composer global config bin-dir --absolute 2>/dev/null)" || _composer_bin=""
  [[ -n "$_composer_bin" && -d "$_composer_bin" ]] && path_prepend "$_composer_bin"
  unset _composer_bin
fi
export PATH