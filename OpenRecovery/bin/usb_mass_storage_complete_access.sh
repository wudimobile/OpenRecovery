#!/sbin/bash

#unmount the sdcard
umount /sdcard
umount /sddata

echo "Enabling USB Mass Storage Complete Access Mode..." 

#mount it to PC
echo "/dev/block/mmcblk0" > /sys/devices/platform/usb_mass_storage/lun0/file

#use imenu to wait for user response
imenu "USB Mass Storage Complete Access Mode Enabled" "Disable" > /dev/null

#unmount it from PC
echo "" > /sys/devices/platform/usb_mass_storage/lun0/file

echo "Disabling USB Mass Storage Complete Access Mode..." 

#mount it back
mount /sddata
mount /sdcard
