#!/bin/bash

mkdir $HOME/golang
mkdir $HOME/golang/src

ln -s /home/pi/.rbenv $HOME/.rbenv
ln -s /home/pi/.nvm $HOME/.nvm
ln -s /home/pi/.local $HOME/.local
ln -s /home/pi/.cargo $HOME/.cargo
ln -s /home/pi/.rustup $HOME/.rustup

echo ./dotfiles/bash_extend >> $HOME/.bashrc

source $HOME/.profile

# remove flag from nvm config
nvm use --delete-prefix v13.2.0 --silent

rbenv install $(rbenv install -l | grep -v - | tail -1)
rbenv global $(rbenv install -l | grep -v - | tail -1)

