#!/bin/sh
set -eu
command -v fnm >/dev/null 2>&1 || exit 0
echo "Installing current Node version..."
eval "$(fnm env)"
fnm install current
fnm default current
