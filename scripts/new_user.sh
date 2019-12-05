adduser $1
adduser $1 sudo
usermod -aG docker $1
usermod -aG devs $1