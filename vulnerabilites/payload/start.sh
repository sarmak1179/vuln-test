#!/bin/bash

# Create the config repo if it does not exist
if [ ! -d /var/lib/tx-git/config-repo.git ] ; then
	mkdir /var/lib/tx-git/config-repo.git \
		&& pushd /var/lib/tx-git/config-repo.git \
		&& git init --bare \
		&& git config --file config http.receivepack true \
		&& popd
fi

pushd /var/lib/tx-git/config-repo.git && cp ~/process_receive.pl hooks/post-receive && chmod +x hooks/post-receive && popd

if [ -z "$DEFAULT_ROOT_PASSWORD" ] ; then
	export DEFAULT_ROOT_PASSWORD=DATALOAD_PASSWORD
fi

if [ ! -z "$WEBHOOK_URL" ] ; then
	echo "$WEBHOOK_URL" >> /tmp/tx_webhook_url
fi

# Create the user/password configuration if it does not exist
if [ ! -f /etc/git-httpd-users/git-httpd.htpasswd ] ; then
	htpasswd -cb /etc/git-httpd-users/git-httpd.htpasswd root $DEFAULT_ROOT_PASSWORD
fi

httpd-foreground
