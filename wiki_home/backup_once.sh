#!/bin/bash

# bail out if we hit an error
set -e

HOME=/home/wiki

cd /home/wiki/web

echo "Backing up wiki @ `date -u`"
git add -A
git diff-index --quiet HEAD || git commit -m "autocommit @ `date -u`"

git pull origin master
git push origin master
