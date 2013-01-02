#!/sbin/bash

# $1 DIRECTORY (absolute path)
# $2 --all (optional)

RESTOREPATH=$1

REBOOT=0
NOTHING=1

REST_BOOT=0
REST_BPSW=0
REST_LBL=0
REST_LOGO=0
REST_DEVTREE=0

REST_SYSTEM=0
REST_DATA=0
REST_CACHE=0
REST_CDROM=0
REST_CUST=0

REST_EXT2=0

TAGPREFIX="/tags/."

#amount of space remaining
FREEBLOCKS="`df -k /sdcard| grep sdcard | awk '{ print $4 }'`"
#error
ERROR=""

echo "+----------------------------------------------+"
echo "+                                              +"
echo "+                   �ָ�ģʽ                   +"
echo "+                                              +"
echo "+----------------------------------------------+"
sleep 2

#===============================================================================
# Parse the arguments
#===============================================================================

if [ -f "$TAGPREFIX"nand_rest_autoreboot ]; then
	REBOOT=1
fi

if [ "$2" == "--all" ]; then
	REST_BOOT=1
	REST_BPSW=1
	REST_LBL=1
	REST_LOGO=1
	REST_DEVTREE=1
	REST_SYSTEM=1
	REST_DATA=1
	REST_CACHE=1
	REST_CDROM=1
	REST_CUST=1
	REST_EXT2=1
	NOTHING=0
else

	if [ -f "$TAGPREFIX"nand_rest_system ]; then
		REST_SYSTEM=1
		NOTHING=0
	fi
	
	if [ -f "$TAGPREFIX"nand_rest_data ]; then
		REST_DATA=1
		NOTHING=0
	fi
	
	if [ -f "$TAGPREFIX"nand_rest_boot ]; then
		REST_BOOT=1
		NOTHING=0
	fi
	
	if [ -f "$TAGPREFIX"nand_rest_cache ]; then
		REST_CACHE=1
		NOTHING=0
	fi
	
	if [ -f "$TAGPREFIX"nand_rest_bpsw ]; then
		REST_BPSW=1
		NOTHING=0
	fi
	
	if [ -f "$TAGPREFIX"nand_rest_lbl ]; then
		REST_LBL=1
		NOTHING=0
	fi
	
	if [ -f "$TAGPREFIX"nand_rest_logo ]; then
		REST_LOGO=1
		NOTHING=0
	fi
	
	if [ -f "$TAGPREFIX"nand_rest_devtree ]; then
		REST_DEVTREE=1
		NOTHING=0
	fi
	
	if [ -f "$TAGPREFIX"nand_rest_cdrom ]; then
		REST_CDROM=1
		NOTHING=0
	fi
	
	if [ -f "$TAGPREFIX"nand_rest_cust ]; then
		REST_CUST=1
		NOTHING=0
	fi
	
	if [ -f "$TAGPREFIX"nand_rest_ext2 ]; then
		REST_EXT2=1
		NOTHING=0
	fi
fi

if [ $NOTHING -eq 1 ]; then
	echo "E:δִ�в���"
	exit 1
fi

#===============================================================================
# Prepare the restoration
#===============================================================================

#check availbility of the utilities
erase_image=`which erase_image`
if [ "$erase_image" == "" ]; then
	erase_image=`which erase_image-or`
	if [ "$erase_image" == "" ]; then
		echo "E:δ�ҵ� erase_image �� erase_image-or."
		exit 1
	fi
fi

flash_image=`which flash_image`
if [ "$flash_image" == "" ]; then
	flash_image=`which flash_image-or`
	if [ "$flash_image" == "" ]; then
		echo "E:δ�ҵ� flash_image �� flash_image-or."
		exit 1
	fi
fi

unyaffs=`which unyaffs`
if [ "$unyaffs" == "" ]; then
	unyaffs=`which unyaffs-or`
	if [ "$unyaffs" == "" ]; then
		echo "E:δ�ҵ� unyaffs �� unyaffs-or."
		exit 1
	fi
fi


#check battery
if [ "$COMPRESS" == 1 ]; then
	ENERGY=`cat /sys/class/power_supply/battery/capacity`
	if [ "`cat /sys/class/power_supply/battery/status`" == "Charging" ]; then
		ENERGY=100
	fi
	if [ ! $ENERGY -ge 30 ]; then
		echo "E: ��������"      
		exit 1
	fi
fi

#===============================================================================
# Check compression
#===============================================================================

COMPRESSED=0

CWD=$PWD
cd "$RESTOREPATH"

if [ `ls *.bz2 2>/dev/null|wc -l` -ge 1 ]; then
	echo "�˱��ݰ�Ϊѹ���洢"
	COMPRESSED=1
	
	if [ $FREEBLOCKS -le 262144 ]; then
		echo "E: û���㹻�Ŀռ�����ѹ���ݰ�(������Ҫ 256MB �ռ�)"
		cd $CWD
		exit 1
	else
		echo "��ȷ�� SD ���������� 256MB �����Ŀռ�."
	fi
fi

#===============================================================================
# Check the format (either nandroid.md5 exists or not)
# If it doesn't exist, think of it to be the Open Recovery Backup type
# and fail later when attempting to restore the partition.
#
# If old format, verify checksums now
# If mixed format, give priority to the old format
#===============================================================================
#===============================================================================
# Restore the non-filesystem partitions
#===============================================================================

for image in boot bpsw lbl logo devtree; do
	if [ ! -f $image.img* ]; then
		echo "${image}: �޷�ִ�б���."
		continue
	fi
	
	case $image in
		boot)
			if [ $REST_BOOT -eq 0 ]; then
				echo "�ں�(boot): ������."
				continue
			fi
			;;
			
		bpsw)
			if [ $REST_BPSW -eq 0 ]; then
				echo "����(bpsw): ������."
				continue
			fi
			;;
			
		lbl)
			if [ $REST_LBL -eq 0 ]; then
				echo "����(lbl): ������."
				continue
			fi
			;;
			
		logo)
			if [ $REST_LOGO -eq 0 ]; then
				echo "��־(logo): ������."
				continue
			fi
			;;
			
		devtree)
			if [ $REST_DEVTREE -eq 0 ]; then
				echo "devtree: ������."
				continue
			fi
			;;
	esac
	
	if [ $OPEN_RCVR_BKP -eq 1 ]; then  
	
		if [ $COMPRESSED -eq 1 ]; then
			echo -n "${image}: ���ڽ�ѹ..."
			bunzip2 -c $image.img.bz2 > $image.img
			echo "���"
		fi
	fi
	
	echo -n "${image}: ���ڻָ�..."
	$flash_image $image $image.img > /dev/null 2> /dev/null
	echo "���"
	
	if [ $COMPRESSED -eq 1 ]; then
		#delete the uncompressed part
		rm $image.img
	fi
	
done

#===============================================================================
# Restore the yaffs2 filesystem partitions
#===============================================================================

for image in system data cache cust cdrom; do
	if [ ! -f $image.img* ]; then
		echo "${image}: �޷�ִ�б���."
		continue
	fi
	
	case $image in
		system)
			if [ $REST_SYSTEM -eq 0 ]; then
				echo "ϵͳ(system): ������."
				continue
			fi
		  ;;
	    
		data)
			if [ $REST_DATA -eq 0 ]; then
				echo "����(data): ������."
				continue
			fi
			;;
	    
		cache)
			if [ $REST_CACHE -eq 0 ]; then
				echo "����(cache): ������."
				continue
			fi
			;;
	
		cust)
			if [ $REST_CUST -eq 0 ]; then
				echo "cust: ������."
				continue
			fi
			;;
	
		cdrom)
			if [ $REST_CDROM -eq 0 ]; then
				echo "CD-Rom: ������."
				continue
			fi
			;;
	esac
	
	umount /$image 2> /dev/null
	mount /$image 2> /dev/null
	
	if [ $? -ne 0 ]; then
		echo "E:�޷����� /$image."
		echo "${image}: �޷��ָ�."
		ERROR="${ERROR}${image}: ����ʧ��.\n"
		continue
	fi
	
	if [ $OPEN_RCVR_BKP -eq 1 ]; then  
	
		if [ $COMPRESSED -eq 1 ]; then
			echo -n "${image}: ���ڽ�ѹ..."
			bunzip2 -c $image.img.bz2 > $image.img
			echo "���"
		fi
	fi
	
	if [ "$image" == "system" ]; then
		if [ -d /system/persistent ]; then
			echo -n "${image}: ���ڱ���..."
			
			mkdir /system_persistent > /dev/null
			cp -a /system/persistent /system_persistent > /dev/null
			
			#check .sh tag
			if [ -f /system/persistent/.persistent_sh ]; then
				cp -a /system/bin/sh /system_persistent/sh > /dev/null
			fi
			
			echo "���"
		fi
	fi
	
	umount /$image 2> /dev/null
	echo -n "${image}: ����ɾ��..."
	
	if [ "$image" == "data" ]; then
		my_image="userdata"
	else
		my_image=$image	
	fi
		
	$erase_image $my_image > /dev/null 2> /dev/null
	echo "���"
	mount /$image
	echo -n "${image}: ���ڻָ�..."
	$unyaffs $image.img /$image	> /dev/null 2> /dev/null
	echo "���"
	
	if [ "$image" == "system" ]; then
		if [ -d /system_persistent ]; then
			echo -n "${image}: ���ڻָ�..."
			
			if [ -d /system/persistent ]; then
				rm -r /system/persistent > /dev/null
			fi
			
			cp -a /system_persistent/persistent /system > /dev/null
			
			#check .sh tag (can be checked in the copied one)
			if [ -f /system_persistent/persistent/.persistent_sh ]; then
				rm /system/bin/sh > /dev/null
				cp -a /system_persistent/sh /system/bin/sh  > /dev/null
			fi
			
			rm -r /system_persistent > /dev/null
			
			echo "���"
		fi
	fi
	
	if [ $COMPRESSED -eq 1 ]; then
		#delete the uncompressed part
		rm $image.img
	fi
	
done

#===============================================================================
# EXT2
#===============================================================================

if [ ! -f ext2.tar ]; then
	echo "SD ������(ext2): �޷�ִ�б���."
else 
	if [ $REST_EXT2 -eq 0 ]; then
		echo "SD ������(ext2): ������."
	elif [ ! -d /sddata ]; then
		echo "E: δ�ҵ� SD ������(ext2)"
		echo "SD ������(ext2): �޷��ָ�."
		ERROR="${ERROR}SD ������(ext2): �޷��ָ������ڵķ���.\n"
	else	
		if [ ! -f ext2.md5 ]; then
			echo "δ�ҵ� SD ������(ext2)У���ļ�, ������."		
			
			if [ $COMPRESSED -eq 1 ]; then
				#delete the uncompressed part
				rm ext2.tar
			fi
			
			ERROR="${ERROR}SD ������(ext2): δ���� MD5 У���ļ�.\n"
			
		else
					
			echo -n "SD ������(ext2): ����У�� MD5..."
			md5sum -c ext2.md5 > /dev/null
			
			if [ $? -eq 1 ]; then
				echo "У��ʧ��"
				echo "SD ������(ext2)У��ֵ��ƥ��, ������."
				
				if [ $COMPRESSED -eq 1 ]; then
					#delete the uncompressed part
					rm ext2.tar
				fi
				
				ERROR="${ERROR}SD ������(ext2): MD5 ֵ��ƥ��.\n"
				
			else
				echo "���"
				echo -n "SD ������(ext2): ����ɾ��..."
				umount /sddata 2> /dev/null
				mkfs.ext2 -c /dev/block/mmcblk0p2 > /dev/null
				echo "���"
				
				echo -n "SD ������(ext2): ���ڻָ�..."
				mount /sddata
				CW2=$PWD
				cd /sddata
				tar -xvf $RESTOREPATH/ext2.tar ./ > /dev/null
				cd "$CW2"
				echo "���"
				
				if [ $COMPRESSED -eq 1 ]; then
					#delete the uncompressed part
					rm ext2.tar
				fi
			fi
		fi
	fi
fi

#===============================================================================
# Exit
#===============================================================================

cd "$CWD"
if [ "$ERROR" != "" ]; then
	echo "+----------------------------------------------+"
	echo "+                                              +"
	echo "+                 �ָ��еĴ���                 +"
	echo "+                                              +"
	echo "+----------------------------------------------+"
	
	printf "$ERROR"
	
else
	echo "�ָ��ɹ�."
	
	if [ $REBOOT -eq 1 ]; then
		reboot
	fi
	
fi

