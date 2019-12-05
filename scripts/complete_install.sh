#!/bin/bash

# file must be ran as sudo

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

# install apt packages
get_package "git g++-8 clang-6.0 openjdk-11-jdk-headless pipenv rbenv"

# prepare directories for installs
mkdir /home/pi/.rbenv
mkdir /home/pi/.rbenv/plugins
mkdir /home/pi/.local/dotnet

# clone repositories
git clone https://github.com/rbenv/ruby-build.git /home/pi/.rbenv/plugins/ruby-build
git clone https://github.com/nvm-sh/nvm.git /home/pi/.nvm

# request tarballs
cd /home/pi/.local && curl 'https://dl.google.com/go/go1.13.4.linux-armv6l.tar.gz' | tar -xz
cd /home/pi/.local/dotnet && curl 'https://download.visualstudio.microsoft.com/download/pr/0b30374c-3d52-45ad-b4e5-9a39d0bf5bf0/deb17f7b32968b3a2186650711456152/dotnet-sdk-3.0.101-linux-arm.tar.gz' | tar -xz

# initalize and install
rbenv init
cd /home/pi/.nvm && git checkout "$(git describe --abbrev=0)" && . nvm.sh
nvm install node

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | HOME=/home/pi sh -s -- --no-modify-path

curl -sSL https://get.docker.com | HOME=/home/pi sh

# # give full permissions to group owner

# chmod -R 771 /home/pi/.rbenv
# chmod -R 771 /home/pi/.local
# chmod -R 771 /home/pi/.nvm

# # make dev group
# chgrp -R devs /home/pi/.rbenv
# chgrp -R devs /home/pi/.local
# chgrp -R devs /home/pi/.nvm

