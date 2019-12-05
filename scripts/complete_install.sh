#!/bin/bash

# file must be ran as sudo

GO_URL='https://dl.google.com/go/go1.13.4.linux-armv6l.tar.gz'
DOTNET_URL='https://download.visualstudio.microsoft.com/download/pr/0b30374c-3d52-45ad-b4e5-9a39d0bf5bf0/deb17f7b32968b3a2186650711456152/dotnet-sdk-3.0.101-linux-arm.tar.gz'

TARGET_DIR='/home/pi'

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
mkdir $TARGET_DIR/.rbenv
mkdir $TARGET_DIR/.rbenv/plugins
mkdir $TARGET_DIR/.local/dotnet

# clone repositories
git clone https://github.com/rbenv/ruby-build.git $TARGET_DIR/.rbenv/plugins/ruby-build
git clone https://github.com/nvm-sh/nvm.git $TARGET_DIR/.nvm

# request tarballs
cd $TARGET_DIR/.local && curl $GO_URL | tar -xz
cd $TARGET_DIR/.local/dotnet && curl $DOTNET_URL | tar -xz

# initalize and install rbenv
/usr/bin/rbenv init
/usr/bin/rbenv install $(/usr/bin/rbenv install -l | grep -v - | tail -1)
/usr/bin/rbenv global $(/usr/bin/rbenv install -l | grep -v - | tail -1)

# initalize and install nvm
cd $TARGET_DIR/.nvm && git checkout "$(git describe --abbrev=0)" && . nvm.sh
nvm install node
nvm use node
nvm use --delete-prefix v13.3.0 --silent

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | HOME=$TARGET_DIR sh -s -- -y --no-modify-path

curl -sSL https://get.docker.com | HOME=$TARGET_DIR sh
