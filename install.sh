#!/bin/bash

### Download dotfiles

DOTFILES_URL="https://github.com/sendelivery/dotfiles/tarball/main"

echo "Downloading Scripts and Templates..."
mkdir -p /tmp/dotfiles
curl -sL "$DOTFILES_URL" \
  | tar -xz --strip-components=1 \
    --include='*/Scripts/*' \
    --include='*/Templates/*' \
    -C /tmp/dotfiles

mkdir -p "$HOME/Scripts" "$HOME/Templates"
cp -r /tmp/dotfiles/Scripts/. "$HOME/Scripts"
cp -r /tmp/dotfiles/Templates/. "$HOME/Templates"

rm -rf /tmp/dotfiles

# Add Scripts directory to the PATH

shell_cfg="$HOME/.zshrc"

if ! [ -e "$shell_cfg" ] ; then
    touch "$shell_cfg"
fi

echo $PATH | grep -q "$HOME/Scripts"

if [ $? -ne 0 ]; then
    echo 'PATH="$HOME/Scripts:$PATH"' >> "$shell_cfg"
fi

# Make the newmac script executable and run it

chmod +x ~/Scripts/newmac
"$HOME/Scripts/newmac"
