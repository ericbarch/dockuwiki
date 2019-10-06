#!/bin/bash

# bail out if we hit an error
set -e

HOME=/home/wiki

cd /home/wiki

while true
do
	echo "Backup script running. Sleeping for 1 hour..."
	sleep 3600

	./backup_once.sh
done

