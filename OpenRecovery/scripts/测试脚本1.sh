#!/sbin/bash

RES=`imenu "您喜欢什么？" "狗狗" "猫咪" "猎豹" "XT701"`
OK=$?
	
echo "答案是 $RES"
