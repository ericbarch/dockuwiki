#!/bin/bash

# bail out if we hit an error
set -e

HOME=/home/wiki
SSH_DIRECTORY=$HOME/.ssh
REPO_PATH=$HOME/web
WEB_OWNERSHIP=wiki:www-data

# ensure the SSH_DOMAIN and REMOTE_URL envs are set
[ -z "$SSH_DOMAIN" ] && echo "Need to set SSH_DOMAIN" && exit 1;
[ -z "$REMOTE_URL" ] && echo "Need to set REMOTE_URL" && exit 1;

# need to check if .ssh dir exists. if not, create it and a key
if [ ! -d "$SSH_DIRECTORY" ]; then
	# Control will enter here if $DIRECTORY doesn't exist.
	echo ".ssh does not exist. creating it and a key"
	mkdir $SSH_DIRECTORY
	ssh-keygen -t rsa -N "" -f $SSH_DIRECTORY/id_rsa

	# pulling in public key of git server
	while true
	do
		if [ -s $SSH_DIRECTORY/known_hosts ]
		then
			echo "SSH keys acquired!"
			break
		else
			echo "scanning SSH host for keys..."
			ssh-keyscan $SSH_DOMAIN > $SSH_DIRECTORY/known_hosts
			sleep 1
		fi
	done

	# configure git
	git config --global user.email "wiki@$HOSTNAME"
	git config --global user.name "wiki"
fi

# print the wiki's public key
echo ""
echo "YOUR WIKI'S SSH PUBLIC KEY (ADD THIS TO YOUR GIT SERVER / HOSTING SERVICE):"
cat $SSH_DIRECTORY/id_rsa.pub
echo ""

if [ ! -d "$REPO_PATH" ]; then
	mkdir $REPO_PATH
fi
cd $REPO_PATH

echo "Script sleeping for 10s before attempt to sync with git..."
sleep 10
echo ""

set_perms () {
	echo "setting proper ownership/permissions..."
	chown -R $WEB_OWNERSHIP $REPO_PATH
	chmod -R 770 $REPO_PATH/conf
	chmod -R 770 $REPO_PATH/data
	chmod -R 750 $REPO_PATH/lib
	chmod -R 770 $REPO_PATH/lib/plugins
	chmod -R 770 $REPO_PATH/lib/tpl
	chmod 770 $REPO_PATH

	return 0
}

# clone the repo. if it's empty, create and commit a new wiki.
if [ ! -d "$REPO_PATH/.git" ]; then
	# not a git repo. let's clone it
	echo "cloning wiki..."
	git clone $REMOTE_URL $REPO_PATH

	if [ "`find .git/objects -type f | wc -l`" -eq "0" ]; then
		echo "cloned empty repo. creating new wiki..."

		# empty git repo, let's extract and commit dokuwiki
		tar -xvzf /tmp/dokuwiki*.tgz -C $REPO_PATH --strip 1

		# copy in gitignore
		cp $HOME/gitignore $REPO_PATH/.gitignore

		set_perms

		git add -A
		git commit -m "wiki created @ `date -u`"
		echo 'wiki created and committed'

		echo 'attempting push...'
		git push -u origin master
	else
		# wiki with commits found
		echo "wiki with commits found. successfully cloned."

		# create dokuwiki gitignore'd dirs
		if [ ! -d "$REPO_PATH/data/cache" ]; then
			mkdir $REPO_PATH/data/cache
			mkdir $REPO_PATH/data/index
			mkdir $REPO_PATH/data/locks
			mkdir $REPO_PATH/data/tmp
		fi

		set_perms
	fi
else
	echo 'wiki repo found. attempting pull...'
	# we pull in case the wiki was modified externally since the last container boot
	git pull origin master
fi
