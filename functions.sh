# !/bin/bash

# Utility functions

function make_temp_dir {
  mkdir temp
  if [ $? ]
  then
    echo "Temp directory created successfully..."
  else
    echo "Error creating temp directory, aborting..."
    exit 1
  fi
}

function make_target_dir {
  mkdir $TARGET_BOOT
  if [ $? ]
  then
    echo "Target mount directory created successfully..."
  else
    echo "Error creating target mount directory, aborting..."
    exit 1
  fi
}

function download_zip {
  # Attempt to download 5 times. Break out on success
  n=1
  while [ $n -le 5 ]
  do
    echo "Downloading zip - Attempt: ${n} out of 5"
    curl -L -O https://downloads.raspberrypi.org/raspbian_lite_latest && break
    echo "Download failed"
    n=$(( $n + 1 ))
  done

  # Check if the attempts ran out. If so, exit program
  if [ $n -gt 5 ]
  then
    echo "Download could not complete. Try again later."
    rm *.zip
    exit 1
  else
    FILE_WITHOUT_SUFFIX=$(ls -1 | awk '$0 !~ /\.img|\.zip/')
    if [ "${FILE_WITHOUT_SUFFIX}" != "" ]
    then
      mv "${FILE_WITHOUT_SUFFIX}" "${FILE_WITHOUT_SUFFIX}.zip" 
    fi
    echo "Download of zip file complete!"
  fi
}

function unzip_img {
  unzip *.zip
  if [ $? ]
  then
    echo "unzip of image successful"
  else
    echo "Error unzipping file, aborting..."
    exit 1
  fi
}

function choose_device {
  # Locate external physical device and confirm target SD card
  local DEVICE_NAMES="$(diskutil list | grep dev | awk '{ print $1 }')"
  local DEVICES="$(diskutil list | grep dev | sed 's/[:|(|)]//g' | awk '{ print $1 " " $2 $3 }')"
  local PREDICTED_DEVICE="$(echo "${DEVICES}" | grep "external,physical" | awk '{ print $1 }')"
  echo "These are the disks currently available:\n"
  echo "${DEVICES}\n"
  read -p "Preferred device seems to be ${PREDICTED_DEVICE}. Confirm (y/n):" CONFIRM
  if [ "${CONFIRM}" = "y" ]; then
    DEVICE="${PREDICTED_DEVICE}"
  else
    read -p "Enter a preferred device name:" PREFERRED_DEVICE
    echo "${DEVICES}" | grep "${PREFERRED_DEVICE}"
    if [ $? ] && [ echo "${DEVICE_NAMES}" | grep "^${DEVICE}$" ]; then
      DEVICE="${PREFERRED_DEVICE}"
    else
      echo "Error: bad device name"
      exit 1
    fi
  fi
}

# Unmount SD Card
function unmount_device {
  # $1 - DEVICE, e.g. /dev/disk2
  echo "Unmounting $1"
  diskutil unmountDisk "$1"
}

function write_image {
  # $1 - DEVICE, e.g. /dev/disk2, $2 - IMG_NAME, filename of img 
  local CONFIRM
  if [ ! $AUTO ]; then
    read -p "Are you sure you want to copy this img to $1? This takes considerable time." $CONFIRM
    if [ "${CONFIRM}" = "y" ]; then
        # Format mounted SD drive
        echo "Copying $2 to $1"
        echo "This takes significant time. Press Ctrl-T for progress."
        echo "Copying roughly 7 GB. Please wait..."
        dd bs=4096 if="$2" of="$1"
    fi
  else
    echo "Copying $2 to $1"
    echo "This takes significant time. Press Ctrl-T for progress."
    echo "Copying roughly 7 GB. Please wait..."
    dd bs=4096 if="$2" of="$1"
  fi
}

# mounting boot partition to directory
function mount_device {
  # $1 - DEVICE, e.g. /dev/disk2
  echo "mounting $1 to ${TARGET_BOOT}..."
  diskutil mountDisk "$1"
}

# start ssh on startup
function set_ssh {
  touch "$TARGET_BOOT"/ssh
  echo "Raspberry pi will start sshd server"
}

# Obtain wifi info
function obtain_network_details {
  local PASSWORD
  local AIRPORT="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"

  SSID="$($AIRPORT -I | grep ' SSID' | awk '{ print $NF }')"
  COUNTRY_CODE="$($AIRPORT -s | grep -m1 "${SSID}" | awk '{ print $6 }')"

  read -s -p "Please enter wifi password for ${SSID}: " $PASSWORD
  PSK="$($AIRPORT -P --password="${PASSWORD}" --ssid="${SSID}")"
}

# Format and write wpa_supplicant.conf
# Note this first write overwrites, the rest append
function write_wpa_conf {
  # $1 - COUNTRY_CODE, $2 - SSID, $3 - PSK
  cat > "$TARGET_BOOT"/wpa_supplicant.conf << EOF
country=$1
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
  ssid="$2"
  psk=$3
  key_mgmt=WPA-PSK
}
EOF

  echo ""
  echo "You can connect to the raspberry pi while connected to the ${SSID} network"
  echo "by ssh-ing into pi@raspberrypi.local. The password is 'raspberry'."
  echo "Once logged in, please run \"sudo /boot/headless-setup.sh\""
  echo ""
}

# Copy scripts into boot directory
function copy_scripts {
  cp -rf scripts/ "$TARGET_BOOT"/scripts/
}

function remove_startup_splash {
    echo $(cat "$TARGET_BOOT/cmdline.txt" | awk '{gsub(" (quiet|splash)", "");print}') > "$TARGET_BOOT"/cmdline.txt
}
