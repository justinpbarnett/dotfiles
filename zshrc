# Add Oh My Posh binary directory to PATH
export PATH=$PATH:/home/jpb/.local/bin

# Load environment variables from .env.local if it exists
if [ -f "$HOME/dotfiles/.env.local" ]; then
    source "$HOME/dotfiles/.env.local"
fi


# Initialize Oh My Posh
eval "$(oh-my-posh init zsh)"

# Fuzzy find from current dir
cdf() {
  local dir
  dir=$(find . -maxdepth 3 -type d -not -path '*/\.*' | fzf --preview 'ls -l {} | batcat --style=numbers --color=always')
  [ -n "$dir" ] && cd "$dir"
}

# Fuzzy find directories in ~/projects and ~/work with preview
ff() {
  local dir
  dir=$(find ~/projects ~/work /mnt/c/dev ~/dotfiles -maxdepth 2 -type d -not -path '.*' | fzf --preview 'ls -l {} | bat --style=numbers --color=always')
  [ -n "$dir" ] && cd "$dir"
}

# Key binding for ff (Ctrl-f)
bindkey '^f' ff-widget

# Create a widget for the ff function
zle -N ff-widget ff

# Alias for csharpier
alias csharpier=~/.dotnet/tools/dotnet-csharpier
