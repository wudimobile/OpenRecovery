#!/sbin/bash

echo "Bash设置" > "$MENU_FILE"
echo "返回:menu:.." >> "$MENU_FILE"

if [ -f /etc/bash/.nobashcolors ]; then
	echo "启用颜色:shell:bash_enable_colors.sh" >> "$MENU_FILE"
else
	echo "禁用颜色:shell:bash_disable_colors.sh" >> "$MENU_FILE"
fi
