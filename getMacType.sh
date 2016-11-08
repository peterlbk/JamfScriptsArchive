#!/bin/sh

SERIAL=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`
SERLAST="${SERIAL:(-4)}"
TYPE=`curl "http://support-sp.apple.com/sp/product?cc=${SERLAST}" | awk -F "<configCode>" '{print$2}' | awk -F "</" '{print$1}'`
echo "You have a $TYPE."