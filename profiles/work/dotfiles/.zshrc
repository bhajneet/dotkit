print -P 'Hello, %n!'

export PROMPT='
%B%F{green}%n@%m: %F{blue}%~%b
%B%(?.%F{black}.%F{red})%#%b%f '

if command -v fnm &>/dev/null; then
  eval "$(fnm env --use-on-cd)"
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/bhajneet/.lmstudio/bin"
# End of LM Studio CLI section

