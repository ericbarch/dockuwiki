# containerwiki
# ---------------------------------------------

# debian w/ ARM qemu
FROM balenalib/armv7hf-debian:stretch

RUN [ "cross-build-start" ]

# install what we need
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get dist-upgrade -y && apt-get install -y openssh-client nginx php-fpm \
    curl php-gd git supervisor php-xml \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# download the latest dokuwiki to /tmp
RUN cd /tmp && curl -O "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz"

# make PHP more secure
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php/7.0/fpm/php.ini

# ensure the pid dir exists for php-fpm
RUN mkdir -p /run/php

# supervisor requires that our processes stay foregrounded
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# clear out any existing configs that ship with nginx
RUN rm /etc/nginx/sites-enabled/*

# load in our nginx config for dokuwiki
ADD dokuwiki.conf /etc/nginx/sites-enabled/

# load in our supervisor config that runs our processes (nginx/php/autobackup)
ADD supervisord.conf /etc/supervisord.conf

# create an unprivileged 'wiki' user to run commands under (w/ access to web content)
RUN useradd -ms /bin/bash wiki && usermod -a -G www-data wiki

# copy scripts/files
COPY wiki_home/* /home/wiki/
RUN chown -R wiki:wiki /home/wiki
RUN chmod +x /home/wiki/*.sh

# publish nginx port
EXPOSE 3000

# get the party started
CMD /home/wiki/start.sh

RUN [ "cross-build-end" ]
