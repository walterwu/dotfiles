#!/bin/bash

# Ask for the administrator password upfront
sudo -v

# Update existing `sudo` time stamp until this script has finished
# https://gist.github.com/cowboy/3118588
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done &> /dev/null &

scripts="$(dirname "$BASH_SOURCE")"
dotfiles="$(cd "$scripts"/.. && pwd)"

#Symlink all dotfiles in list into ~/dotfiles
echo "Symlinking files..."
folders=(vim homebrew)
for folder in "${folders[@]}"; do
    for file in "$dotfiles"/"$folder"/*; do
        ln -s "$file" "$HOME"/."$(basename "$file")"
    done
done

# Install Homebrew
echo "checking if Homebrew is installed..."
which -s brew
if [[ $? != 0 ]] ; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Homebrew already installed."
    brew update
fi

brew tap homebrew/bundle
brew bundle --global
echo "Homebrew installation complete."

# Install zsh and Oh My Zsh
echo "checking if zsh is installed..."
if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Install Oh My Zsh if it isn't already present
    if [[ ! -d $dir/oh-my-zsh/ ]]; then
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
      chsh -s $(which zsh)
    fi
else
  # If zsh isn't installed, tell user to install zsh
  echo "We'll install zsh, then re-run this script!"
  brew install zsh
  exit
fi

# Symlink Oh My Zsh to ~/dotfiles/zsh/oh-my-zsh
ln -s "$dotfiles"/zsh/oh-my-zsh "$HOME"/.oh-my-zsh

# Symlink .zsh config file to ~/dotfiles/zsh/zshrc.
ln -s "$dotfiles"/zsh/zshrc "$HOME"/.zshrc

# Install the Solarized Dark theme for iTerm
open "${HOME}/dotfiles/iterm/themes/Atom.itermcolors"

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Reload zsh settings
source ~/.zshrc