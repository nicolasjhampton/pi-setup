# pi-setup
A simple script to setup my raspberry pi the way I like it


## Instructions

Mount the sd-card and run `sudo sd-setup.sh`

Plug the card into the pi and plug the pi in.

ssh into pi@raspberrypi.local with password 'raspberry'

cp -rf /boot/scripts/ ./scripts

run `sudo ./headless-setup.sh <hostname>`

relogin in as pi

run `sudo ./scripts/complete_install.sh`

create a new user with `sudo ./scripts/new_user.sh <name>`

logout and login as the new user

run `sudo ../pi/scripts/user_setup.sh .` in the new users home directory

run `../pi/scripts/check_lang.sh` and see if any versions can't be shown