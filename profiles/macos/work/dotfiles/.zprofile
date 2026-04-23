setopt NO_CASE_GLOB
setopt AUTO_CD

alias minecraft='ssh minecraft.bhajneet.com'
alias nas='ssh nas.bhajneet.com'
alias ssh-games='ssh games.bhajneet.com'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias l='eza -a1 --group-directories-first --git'
alias ll='eza -al --group-directories-first --git --no-permissions --octal-permissions'

alias search='brew search'
alias install='brew install'
alias update='brew update'
alias upgrade='brew upgrade'
alias upup='brew update && brew upgrade'

alias d='cd ~/dev'
alias dev='cd ~/dev'
alias s='cd ~/dev/shabados'
alias mobile='cd ~/dev/shabados/mobile'
alias website='cd ~/dev/shabados/website'
alias presenter='cd ~/dev/shabados/presenter'
alias gu='cd ~/dev/shabados/gurmukhiutils'

alias c='code .'

alias g='git'
alias gs='git status'
alias gt='git checkout'
alias gn='git checkout -b'
alias gl='git log'
alias gb='git branch'
alias grm='git branch -d'

alias ni='npm i'
alias ns='npm start'
alias nis='npm i && npm start'
alias nr='npm run'
alias nu='npm update'

alias h='hatch'
alias hep='hatch env prune'
alias hr='hatch run'
alias hpr='hatch env prune && hatch run'

alias love="/Applications/love.app/Contents/MacOS/love"

alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

function gclean {
  git checkout -- .
  git clean -f
  git reset --hard
}

function gresh {
  git fetch upstream main
  git rebase upstream/main
}

function gsync() {
  if ! git remote -v | grep -q 'upstream'; then
    echo "Please enter the upstream git url:";
    read url;
    git remote add upstream "$url";
  fi

  if test -n "$(git status --porcelain)"; then
    echo "Please clean git status (can use gclean)";
    return 0;
  fi

  BRANCH=$(git rev-parse --abbrev-ref HEAD)

  git pull --ff-only upstream $BRANCH

  echo ""
  echo "If upstream and local have diverged,"
  echo "run git reset upstream/$BRANCH"
  echo "and add --hard to conk the working dir"
}

export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
