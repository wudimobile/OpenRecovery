#!/sbin/bash

rm -Rf /data/dalvik-cache/*
[ -d /sddata/dalvik-cache ] && rm -Rf /sddata/dalvik-cache/*
echo "Succesfully wiped dalvik-cache."
