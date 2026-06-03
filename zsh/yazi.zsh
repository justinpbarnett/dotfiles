# y -> yazi (restores cwd on exit; see https://yazi-rs.github.io/docs/quick-start)
if ! command -v yazi &>/dev/null; then
  return 0
fi

function y() {
  local tmp cwd
  tmp="$(mktemp "${TMPDIR:-/tmp}/yazi-cwd.XXXXXX")" || return 1
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}