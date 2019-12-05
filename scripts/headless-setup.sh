#!/bin/bash

apt -y update && apt -y upgrade 

# Setup boot to term
systemctl set-default multi-user.target
ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $SUDO_USER --noclear %I \$TERM
EOF

# reset password for root user
passwd pi

# create devs group
groupadd devs

# Create an adminstrative user
read -p "Please add a sudouser: " username
adduser "${username}"
adduser "${username}" sudo

# add users to devs
usermod -a -G devs pi
usermod -a -G devs "${username}"

# add users to docker
usermod -a -G docker pi
usermod -a -G docker "${username}"

chgrp devs /home/pi
chmod g+s /home/pi

# Extend ssh timeout
cat > /etc/ssh/sshd_config << EOF
ClientAliveInterval 120
ClientAliveCountMax 720
EOF

# set new hostname
sed -i "s/raspberrypi/$1/" /etc/hosts
echo "$1" > /etc/hostname

# Download ngrok and install
mkdir /home/pi/.local/
curl https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip -L -o /home/pi/.local/ngrok.zip
unzip -d /home/pi/.local/ /home/pi/.local/ngrok.zip
rm /home/pi/.local/ngrok.zip

# Configure ngrok
read -s -p "Please enter ngrok authtoken: " authtoken
read -p "Please enter ngrok remote address: " remoteaddr
cat > /home/pi/.local/ngrok.yml << EOF
authtoken: ${authtoken}
tunnels:
  ssh-access:
    addr: 22
    proto: tcp
    remote_addr: ${remoteaddr}
EOF

# Autostart ngrok on start
cat >> /home/pi/.profile << 'EOF'
PATH=$PATH:/home/pi/.local
ngrok start --config /home/pi/.local/ngrok.yml --all
EOF

reboot

