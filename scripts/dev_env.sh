#!/bin/bash

function get_package {
  if [[ "$OSTYPE" == "linux"* ]]; then
    apt -y install $1
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    brew install $1
  fi
}

if [[ "$OSTYPE" == "linux"* ]]; then
  apt -y update && apt -y upgrade
elif [[ "$OSTYPE" == "darwin"* ]]; then
  brew update && brew upgrade
fi

get_package "zsh neovim tmux"

chsh -s /usr/local/bin/zsh

git clone https://github.com/bhilburn/powerlevel9k.git ~/.powerlevel9k
echo 'source  ~/.powerlevel9k/powerlevel9k.zsh-theme' >> ~/.zshrc

echo ./dotfiles/powerlevel_config > $HOME/.powerlevel_config
echo 'source  ~/.powerlevel_config' >> ~/.zshrc

mkdir $HOME/.fonts && cd $HOME/.fonts
git clone https://github.com/ryanoasis/nerd-fonts.git
cp './nerd-fonts/patched-fonts/Meslo/M/Regular/complete/Meslo LG M Regular Nerd Font Complete.ttf' 'Meslo LG M Regular Nerd Font Complete.ttf'
fc-cache -v -f
