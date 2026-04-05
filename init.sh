#!/bin/bash

mkdir -p "$HOME/Scripts" "$HOME/Templates"

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
grep -q "git@github.com:sendelivery/dotfiles.git" "$DOTFILES_DIR/.git/config"

if [ $? -eq 0 ]; then
    echo "Local repository detected, copying files..."
    cp -r "$DOTFILES_DIR/Scripts/." "$HOME/Scripts"
    cp -r "$DOTFILES_DIR/Templates/." "$HOME/Templates"
else
    DOTFILES_URL="https://github.com/sendelivery/dotfiles/tarball/main"
    echo "Downloading Scripts and Templates..."
    mkdir -p /tmp/dotfiles
    curl -sL "$DOTFILES_URL" \
    | tar -xz --strip-components=1 \
        --include='*/Scripts/*' \
        --include='*/Templates/*' \
        -C /tmp/dotfiles

    cp -r /tmp/dotfiles/Scripts/. "$HOME/Scripts"
    cp -r /tmp/dotfiles/Templates/. "$HOME/Templates"

    rm -rf /tmp/dotfiles
fi

# Make the newmac script executable and run it
chmod +x "$HOME/Scripts/reinstall_tools"
"$HOME/Scripts/reinstall_tools"
