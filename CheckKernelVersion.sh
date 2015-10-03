#!/bin/sh

kernelv="/private/tmp/kernelv.txt"
touch $kernelv

kernel="`uname -r | awk '{print substr($0,0,2)}'`"

if [ $kernel == 15 ]; then
result="10.11"
else
	if [ $kernel == 14 ]; then
		result="10.10"
		else
			if [ $kernel == 13 ]; then
				result="10.9"
				else
					if [ $kernel == 12 ]; then
						result="10.8"
					else
						if [ $kernel == 11 ]; then
							result="10.7"
								else
							result="pre-10.7"
						fi
					fi 
			fi
	fi
fi

echo "</result>$result</result>"

if [ -f /private/tmp/kernelv.txt ]; then
   rm /private/tmp/kernelv.txt
fi
