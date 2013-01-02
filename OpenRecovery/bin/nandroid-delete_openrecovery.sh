#!/sbin/bash

# $1 DIRECTORY (absolute path)

#really want to?
BACKUP_NAME=`basename "$1"`

USER_ACTION=`imenu "真的要删除${BACKUP_NAME}吗?" 否 是`

if [ $USER_ACTION -eq 2 ]; then
	echo "正在删除${BACKUP_NAME}..."
	rm -fr "$1"
else
	echo "未做任何更改"
fi
