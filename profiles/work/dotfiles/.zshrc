print -P 'Hello, %n!'

export PROMPT='
%B%F{green}%n@%m: %F{blue}%~%b
%B%(?.%F{default}.%F{red})%#%b%f '

unset VISUAL EDITOR
local edit_cmds=("kak" "nano")
for cmd in $edit_cmds; do
  if (( $+commands[${cmd[(w)1]}] )); then
    export VISUAL=$cmd
    export EDITOR=$cmd
    break
  fi
done

if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd)"
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/bhajneet/.lmstudio/bin"
# End of LM Studio CLI section

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
