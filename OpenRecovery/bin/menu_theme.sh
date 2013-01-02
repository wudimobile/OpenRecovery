#!/sbin/bash

THEME_DIR=/sdcard/OpenRecovery/res.

echo "主题设置" > "$MENU_FILE"
echo "返回:menu:.." >> "$MENU_FILE"

for THEME in "$THEME_DIR"*; do
	#omit the default one
	if [ $THEME != "$THEME_DIR" ]
	then
		BASE_THEME="$(basename $THEME)"
		THEME_NAME=`awk 'NR==1' $THEME/name`
		echo "$THEME_NAME:shell:set_theme.sh $BASE_THEME" >> "$MENU_FILE"
	fi
done
