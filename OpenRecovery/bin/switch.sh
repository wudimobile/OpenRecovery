#!/sbin/bash

export PATH="$PATH:/bin:/sbin"

# arguments
# $1 the phone suffix
#
# SHOLS - Milestone (A853, XT702)
# STCU  - Sholes Tablet (XT701)
# STR   - Milestone XT720 (XT720)
# JRD   - Defy (MB525) - not implemented yet
# STAB  - Milestone 2 (A953) - not implemented yet

#flags
#===============================================================================

INSTALL_COMMAND=0
EMMC=0
ROOT="/"

if [ "$1" == "STCU" ]; then
	NOCUST=1
else
	NOCUST=0
	
	if [ "$1" == "SHOLS" ]; then
		INSTALL_COMMAND=1
# fstab has to be patched only after 2ndboot so for now let's set EMMC to 1 
		EMMC=1
		ROOT="/cache/OpenRecovery/"
		mkdir /cache/OpenRecovery
		mkdir ${ROOT}etc
    cp -fR /sbin ${ROOT}
	fi
fi

if [ "$1" == "JRD" ]; then
	NOCUST=1
	EMMC=1
fi

#post-installation
#===============================================================================

#put the command into the cache - if it doesn't exist
if [ $INSTALL_COMMAND -eq 1 ]; then
	if [ ! -f /cache/recovery/command ]; then
		cp -f /sdcard/OpenRecovery/etc/command /cache/recovery/command
		chmod 0644 /cache/recovery/command
	fi
fi

#basic initialization
#===============================================================================

#dirs

mkdir /cdrom
chmod 0755 /cdrom

if [ $NOCUST -eq 0 ]; then
	mkdir /cust
	chmod 0755 /cust
fi

#fstab
cp -f "/sdcard/OpenRecovery/etc/fstab.$1" ${ROOT}etc/fstab
chmod 0644 ${ROOT}etc/fstab

cp -f /sdcard/OpenRecovery/etc/mtab ${ROOT}etc/mtab
chmod 0644 ${ROOT}etc/mtab

#bash etc
mkdir ${ROOT}etc/bash
chmod 0644 ${ROOT}etc/bash

cp -f "/sdcard/OpenRecovery/etc/bash/bashrc.$1" ${ROOT}etc/bash/bashrc
chmod 0644 ${ROOT}etc/bash/bashrc

#bash - check if colors are disabled
if [ -f /sdcard/OpenRecovery/etc/bash/.nobashcolors ]; then
	cp -f /sdcard/OpenRecovery/etc/bash/.nobashcolors ${ROOT}etc/bash/.nobashcolors
	chmod 0644 ${ROOT}etc/bash/.nobashcolors
fi

#our little timezone hack
cp -f /sdcard/OpenRecovery/etc/timezone ${ROOT}etc/timezone
chmod 0644 ${ROOT}etc/timezone

#keyboard layout
cp -f /sdcard/OpenRecovery/etc/keyboard ${ROOT}etc/keyboard
chmod 0644 ${ROOT}etc/keyboard

# Patch fstab
if [ $EMMC -eq 0 ]; then

	MTDBLOCK_SYSTEM=$(/sbin/cat /proc/mtd | /sbin/grep "system")
	MTDBLOCK_SYSTEM=${MTDBLOCK_SYSTEM%%:*}
	MTDBLOCK_SYSTEM=${MTDBLOCK_SYSTEM##mtd}
	MTDBLOCK_SYSTEM="\/dev\/block\/mtdblock$MTDBLOCK_SYSTEM"
	
	MTDBLOCK_DATA=$(/sbin/cat /proc/mtd | /sbin/grep "userdata")
	MTDBLOCK_DATA=${MTDBLOCK_DATA%%:*}
	MTDBLOCK_DATA=${MTDBLOCK_DATA##mtd}
	MTDBLOCK_DATA="\/dev\/block\/mtdblock$MTDBLOCK_DATA"
	
	MTDBLOCK_CDROM=$(/sbin/cat /proc/mtd | /sbin/grep "cdrom")
	MTDBLOCK_CDROM=${MTDBLOCK_CDROM%%:*}
	MTDBLOCK_CDROM=${MTDBLOCK_CDROM##mtd}
	MTDBLOCK_CDROM="\/dev\/block\/mtdblock$MTDBLOCK_CDROM"
	
	MTDBLOCK_CACHE=$(/sbin/cat /proc/mtd | /sbin/grep "cache")
	MTDBLOCK_CACHE=${MTDBLOCK_CACHE%%:*}
	MTDBLOCK_CACHE=${MTDBLOCK_CACHE##mtd}
	MTDBLOCK_CACHE="\/dev\/block\/mtdblock$MTDBLOCK_CACHE"
	
	sed -i "s/MTDBLOCKSYSTEM/$MTDBLOCK_SYSTEM/g" /etc/fstab
	sed -i "s/MTDBLOCKDATA/$MTDBLOCK_DATA/g" /etc/fstab
	sed -i "s/MTDBLOCKCDROM/$MTDBLOCK_CDROM/g" /etc/fstab
	sed -i "s/MTDBLOCKCACHE/$MTDBLOCK_CACHE/g" /etc/fstab
	
	if [ $NOCUST -eq 0 ]; then
	
		MTDBLOCK_CUST=$(/sbin/cat /proc/mtd | /sbin/grep "cust")
		MTDBLOCK_CUST=${MTDBLOCK_CUST%%:*}
		MTDBLOCK_CUST=${MTDBLOCK_CUST##mtd}
		MTDBLOCK_CUST="\/dev\/block\/mtdblock$MTDBLOCK_CUST"
		
		sed -i "s/MTDBLOCKCUST/$MTDBLOCK_CUST/g" /etc/fstab
	fi
fi

#terminfo
cp -fR /sdcard/OpenRecovery/etc/terminfo/ ${ROOT}etc
chmod -R 0644 ${ROOT}etc/terminfo

cp -f /sdcard/OpenRecovery/sbin/usbd ${ROOT}sbin/usbd
chmod 0755 ${ROOT}sbin/usbd

cp -f /sdcard/OpenRecovery/sbin/battd ${ROOT}sbin/battd
chmod 0755 ${ROOT}sbin/battd

cp -f /sdcard/OpenRecovery/sbin/linker ${ROOT}sbin/linker
chmod 0755 ${ROOT}sbin/linker


#Nandroid
cp -f /sdcard/OpenRecovery/sbin/dump_image-or ${ROOT}sbin/dump_image-or
chmod 0755 ${ROOT}sbin/dump_image-or
ln -s /sbin/dump_image-or ${ROOT}sbin/dump_image
chmod 0755 dump_image

cp -f /sdcard/OpenRecovery/sbin/e2fsck-or ${ROOT}sbin/e2fsck-or
chmod 0755 ${ROOT}sbin/e2fsck-or
ln -s /sbin/e2fsck-or ${ROOT}sbin/e2fsck
chmod 0755 e2fsck

cp -f /sdcard/OpenRecovery/sbin/tune2fs ${ROOT}sbin/tune2fs
chmod 0755 ${ROOT}sbin/tune2fs

cp -f /sdcard/OpenRecovery/sbin/parted ${ROOT}sbin/parted
chmod 0755 ${ROOT}sbin/parted

cp -f /sdcard/OpenRecovery/sbin/erase_image-or ${ROOT}sbin/erase_image-or
chmod 0755 ${ROOT}sbin/erase_image-or
ln -s /sbin/erase_image-or ${ROOT}sbin/erase_image
chmod 0755 erase_image

cp -f /sdcard/OpenRecovery/sbin/flash_image-or ${ROOT}sbin/flash_image-or
chmod 0755 ${ROOT}sbin/flash_image-or
ln -s /sbin/flash_image-or ${ROOT}sbin/flash_image
chmod 0755 flash_image

cp -f /sdcard/OpenRecovery/sbin/mkyaffs2image-or ${ROOT}sbin/mkyaffs2image-or
chmod 0755 ${ROOT}sbin/mkyaffs2image-or
ln -s /sbin/mkyaffs2image-or ${ROOT}sbin/mkyaffs2image
chmod 0755 mkyaffs2image

cp -f /sdcard/OpenRecovery/sbin/unyaffs-or ${ROOT}sbin/unyaffs-or
chmod 0755 ${ROOT}sbin/unyaffs-or
ln -s /sbin/unyaffs-or ${ROOT}sbin/unyaffs
chmod 0755 unyaffs

#Updater
cp -f /sdcard/OpenRecovery/sbin/updater-or ${ROOT}sbin/updater-or
chmod 0755 ${ROOT}sbin/updater-or
rm -f ${ROOT}sbin/updater
ln -s /sbin/updater-or ${ROOT}sbin/updater
chmod 0755 /sbin/updater
cp -f /sdcard/OpenRecovery/sbin/script-updater ${ROOT}sbin/script-updater
chmod 0755 ${ROOT}sbin/script-updater

#Interactive menu
cp -f /sdcard/OpenRecovery/sbin/imenu ${ROOT}sbin/imenu
chmod 0755 ${ROOT}sbin/imenu

#adbd
cp -f /sdcard/OpenRecovery/sbin/adbd_bash ${ROOT}sbin/adbd
chmod 0755 ${ROOT}sbin/adbd

#create a bin folder for the scripts
cp -fR /sdcard/OpenRecovery/bin/ $ROOT
chmod -R 0755 ${ROOT}bin

#remove self copy
rm ${ROOT}bin/switch.sh

#lib and modules
mkdir ${ROOT}lib
cp -fR /sdcard/OpenRecovery/lib/ $ROOT
chmod -R 0644 ${ROOT}lib

#chek linux version
LVER=`uname -r | awk '{split($0,a,"-"); print a[1]}'`

#modules
if [ -d "/lib/modules/$LVER" ]; then

	MODPATH="/lib/modules/$LVER"

	#MMC-fix
	MMCFIX_MODULE="$MODPATH/mmcfix.ko"
	if [ -f "$MMCFIX_MODULE" ]; then		
		insmod "$MMCFIX_MODULE"
	fi

	#ext2/3/4 partition on sdcard
	if [ -b /dev/block/mmcblk0p2 ] && [ -f "$MODPATH/ext4.ko" ] && [ -f "$MODPATH/jbd2.ko" ] && [ -f "$MODPATH/crc16.ko" ]; then
		mkdir /sddata
		insmod "$MODPATH/jbd2.ko"
		insmod "$MODPATH/crc16.ko"
		insmod "$MODPATH/ext4.ko"
		echo "/dev/block/mmcblk0p2          /sddata         auto            defaults        0 0" >> /etc/fstab
		e2fsck -p /dev/block/mmcblk0p2 
	fi
	
	#partitions
	PARTITIONS_MODULE="$MODPATH/part-$1.ko"
	if [ -f /etc/bootstrap ] && [ -f "$PARTITIONS_MODULE" ]; then		
		insmod "$PARTITIONS_MODULE"
	fi
fi

#res - read the theme first
rm -fR /res

if [ -f /sdcard/OpenRecovery/etc/theme ]; then
	cp -f /sdcard/OpenRecovery/etc/theme ${ROOT}etc/theme
	chmod 0644 ${ROOT}etc/theme
	
	THEME=`awk 'NR==1' ${ROOT}etc/theme`
	
	if [ -d /sdcard/OpenRecovery/$THEME ]; then
		cp -fR /sdcard/OpenRecovery/$THEME/ $ROOT
		mv -f ${ROOT}${THEME} ${ROOT}res
	else
		cp -fR /sdcard/OpenRecovery/res.or/ $ROOT
		mv -f ${ROOT}res.or ${ROOT}res
	fi
else
	cp -fR /sdcard/OpenRecovery/res.or/ $ROOT
	mv -f ${ROOT}res.or ${ROOT}res
fi

chmod -R 0644 ${ROOT}res

#menus
mkdir ${ROOT}menu
chmod 0644 ${ROOT}menu
export MENU_DIR=${ROOT}menu
cp -fR /sdcard/OpenRecovery/menu/ $ROOT

#tags
mkdir ${ROOT}tags
chmod 0644 ${ROOT}tags
cp -fR /sdcard/OpenRecovery/tags/ $ROOT


#Launch Open Recovery
#==============================================================================

#rm /cache/recovery/command
rm /cache/OpenRecovery/sbin/recovery

cp -f "/sdcard/OpenRecovery/sbin/open_rcvr."$1 ${ROOT}sbin/recovery
chmod 0755 ${ROOT}sbin/recovery

overclock.sh

#Check if we are supposed to call 2nd-init or just restart the binaries
if [ -d "/sdcard/OpenRecovery/2ndinit.$1" ]; then
	DIR="/sdcard/OpenRecovery/2ndinit.$1"
	
	cp -f "$DIR/default.prop" /default.prop
	chmod 0644 /default.prop
		
	cp -f "$DIR/init.rc" /init.rc
	chmod 0755 init.rc
							
	#2nd-init (new init script will kill old adb and recovery)
	#don't use exec, the primary recovery would finish too soon
	/sdcard/OpenRecovery/sbin/2nd-init
	
	#sleep until the sleep is killed or timeout one minute
	sleep 60	
else
	
	#just call post_switch.sh
	post_switch.sh
	
fi
