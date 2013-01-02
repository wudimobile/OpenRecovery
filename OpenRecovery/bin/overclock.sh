#!/sbin/bash

echo "6 1000000000 62" > /proc/overclock/mpu_opps
echo "5 850000000 50" > /proc/overclock/mpu_opps
echo "4 720000000 47" > /proc/overclock/mpu_opps
echo "3 600000000 40" > /proc/overclock/mpu_opps
echo "2 500000000 33" > /proc/overclock/mpu_opps
echo "1 250000000 30" > /proc/overclock/mpu_opps

echo "performance" /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
