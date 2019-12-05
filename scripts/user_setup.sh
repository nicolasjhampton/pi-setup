#!/bin/bash

SOURCE_DIR='/home/pi'

mkdir $1/golang
mkdir $1/golang/src

ln -s $SOURCE_DIR/.rbenv $1/.rbenv
ln -s $SOURCE_DIR/.nvm $1/.nvm
ln -s $SOURCE_DIR/.local $1/.local
ln -s $SOURCE_DIR/.cargo $1/.cargo
ln -s $SOURCE_DIR/.rustup $1/.rustup

cat $SOURCE_DIR/scripts/dotfiles/bash_extend >> $1/.bashrc

source $1/.profile

# remove flag from nvm config
# . $1/.nvm/nvm.sh
# nvm use --delete-prefix v13.2.0 --silent

