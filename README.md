# dotfiles

A collection of configuration files and settings for development environment setup.

## Contents

- Shell configurations
- Editor settings
- Development tools
- System preferences

## Installation

1. Clone this repository
2. Install `stow` if not already installed
3. Run `stow` to symlink dotfiles to your home directory: `stow .`
4. Customize settings as needed for your system

### FZF 

You may need to recompile the telescope-fzf-native extension in the `.local` folder
## Stow

This repository uses [GNU Stow](https://www.gnu.org/software/stow/) to manage symlinks. Stow automatically creates symbolic links from the dotfiles directory to your home directory, organizing files by directory structure.

To install a specific package: `stow <package_name>`
To remove symlinks: `stow -D <package_name>`

## Packages

packages.txt defines a number of packages to be installed via the setup script. 
Additionally, the setup script installs some tools manually, which cannot be installed via package managers.

## Usage

See individual configuration files for specific usage instructions.

## License

[Add your license here]
