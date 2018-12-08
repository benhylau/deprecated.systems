#!/usr/bin/env bash

cd /opt/dehydrated/

# Request SSL cert with a maximum of 3 failed attempts
count=0
false
while [ $? -ne 0 ] && [ $count -lt 3 ]
do
	if [ $count -eq 0 ]
	then
    		echo "Requesting SSL certificate"
	else
		# Sleep 60 seconds between retries
		echo "Sleeping for 60 seconds before retry"
		sleep 60
		echo "Requesting SSL certificate (retry: $count)"
	fi

	# Request SSL cert with dehydrated
	./dehydrated -c -f config

	let count=count+1
done

# Log SSL cert request status
if [ $? -ne 0 ]
then
	echo "SSL certificate request failed"
	exit 1
fi
