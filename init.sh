#!/bin/bash

tmp_dir="/tmp/dotfiles"
mkdir -p "$tmp_dir"

current_dir="$(cd "$(dirname "$0")" && pwd)"
grep -q "git@github.com:sendelivery/dotfiles.git" "$current_dir/.git/config"

if [ $? -eq 0 ]; then
    echo "Local repository detected, copying files..."
    cp -r "$current_dir/Scripts" "$tmp_dir"
    cp -r "$current_dir/Templates" "$tmp_dir"
else
    DOTFILES_URL="https://github.com/sendelivery/dotfiles/tarball/main"
    echo "Downloading files..."
    curl -sL "$DOTFILES_URL" \
    | tar -xz --strip-components=1 \
        --include='*/Scripts/*' \
        --include='*/Templates/*' \
        -C "$tmp_dir"
fi

# Make the reinstall_tools script executable and run it
chmod +x "$tmp_dir/Scripts/reinstall_tools"
"$HOME/Scripts/reinstall_tools" $tmp_dir

# Cleanup
rm -rf "$tmp_dir"
