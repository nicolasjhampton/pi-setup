#!/bin/bash

source ./constants.sh
source ./functions.sh

# Program start

# Part one: Get image file

# Turn spotlight off
sudo mdutil -a -i off

# create temp directory if none currently exist
if [ ! -d ./temp ]; then
  make_temp_dir
else
  echo "Found previously existing temp directory..."
fi

# change directory to temp directory
echo "Switching to temp directory..."
cd ./temp

# download zip file of image from internet
if [ ! -r *.zip ] && [ ! -r *.img ]
then
  download_zip
else
  if [ -r *.img ]
  then
    echo "Img file exists, skipping unzip..."
  fi
fi

# Extract image file from zip
if [ -r *.zip ] && [ ! -r *.img ]
then
  unzip_img
fi

# Check for image file
if [ ! -r *.img ]
then
  echo "Can't find image file. Please try again."
  # Something weird must have happened. Wipe the directory clean and try again.
  cd ..
  rm -rf ./temp
  exit 1
else 
  IMG_NAME="$(ls -1 | grep img)"
  echo "Image extracted to file ${IMG_NAME}"
fi

if [ ! $DEVICE ]; then
  choose_device
fi

unmount_device $DEVICE

write_image $DEVICE $IMG_NAME

mount_device $DEVICE

cd ..

set_ssh

copy_scripts

remove_startup_splash

if [ ! $COUNTRY_CODE ] || [ ! $SSID ] || [ ! $PSK ]; then
  obtain_network_details
fi

write_wpa_conf $COUNTRY_CODE $SSID $PSK

unmount_device $DEVICE 

sudo mdutil -a -i on

exit 0
