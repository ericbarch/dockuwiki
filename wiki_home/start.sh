#!/bin/bash

# bail out if we hit an error
set -e

# ensure the wiki is properly setup (run as the wiki user)
su -c "/home/wiki/bootstrap_wiki.sh" -m "wiki" 

# start php/nginx/autobackup via supervisor
echo "Starting supervisord. All child processes will be started WITHOUT root privileges"
exec /usr/bin/supervisord -c /etc/supervisord.conf
