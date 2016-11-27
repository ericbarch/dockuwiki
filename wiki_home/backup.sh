#!/bin/bash

# bail out if we hit an error
set -e

HOME=/home/wiki

cd /home/wiki/web

while true
do
	echo "Backup script running. Sleeping for 1 hour..."
	sleep 3600

	echo "Backing up wiki @ `date -u`"
	git add -A
	git commit -m "autocommit @ `date -u`"

	git pull origin master
	git push origin master
done

