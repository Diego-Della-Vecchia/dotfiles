#!/usr/bin/env bash

# Install system packages
grep -vE '^\s*#|^\s*$' packages.txt | xargs sudo apt install -y

# Install NVM
if ! command -v nvm &>/dev/null; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.6/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Install pulumi
echo "Installing Pulumi..."
curl -fsSL https://get.pulumi.com | sh

# Install pulumi esc
echo "Installing Pulumi ESC..."
curl -fsSL https://get.pulumi.com/esc/install.sh | sh

# Install Neovim (latest)
    echo "Installing Neovim..."
    sudo snap install nvim --classic

# Install Lazygit
LAZYGIT_VER=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VER/lazygit_${LAZYGIT_VER}_Linux_x86_64.tar.gz"

tar xf lazygit.tar.gz lazygit
sudo mv lazygit /usr/local/bin/
rm lazygit.tar.gz

# Install win32yank
curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/
