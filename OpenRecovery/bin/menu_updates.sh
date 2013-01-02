#!/sbin/bash

UPDATES_DIR=/sdcard/OpenRecovery/updates

#recreate the file
echo "安装升级包" > "$MENU_FILE"
echo "返回:menu:.." >> "$MENU_FILE"

if [ -d $UPDATES_DIR ]
then
	for UPDATE in "$UPDATES_DIR/"*.zip; do
		#omit the default one
		if [ "$UPDATE" != "$UPDATES_DIR/*.zip" ]
		then
			BASE_UPDATE=`basename "$UPDATE"`
			echo "$BASE_UPDATE:update:SDCARD:OpenRecovery/updates/$BASE_UPDATE" >> "$MENU_FILE"
		fi
	done
fi
