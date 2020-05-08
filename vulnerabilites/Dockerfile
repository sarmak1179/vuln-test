# taking the latest image from docker registry for Apache Httpd server
FROM httpd:2.4


ENV	HCLTXAPP_USER=hcltxapp \
	HCLTXAPP_UID=1010 \
	HCLTXAPP_GID=1010 \
	WEBHOOK_URL=http://tx-config-server:8888/update-resources
	
RUN groupadd -g $HCLTXAPP_GID $HCLTXAPP_USER \
    &&  useradd -m -u $HCLTXAPP_UID -g $HCLTXAPP_GID $HCLTXAPP_USER \
    && apt-get update \
    && apt-get install -y git gitweb curl \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/ssl/private/ssl-cert-snakeoil.key
	
# Overwrite the default  httpd conf  with httpd.conf which contains port changes, additional modules, URL rewriting and Header rewrites.
COPY payload/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY payload/gitweb.conf /etc/gitweb.conf
COPY payload/start.sh /home/$HCLTXAPP_USER/start.sh
COPY payload/process_receive.pl /home/$HCLTXAPP_USER/process_receive.pl

#Providing permission to base dir for apache
RUN mkdir /var/lib/tx-git /etc/git-httpd-users \
    && chown -R $HCLTXAPP_USER /usr/local/apache2 /var/lib/tx-git /etc/git-httpd-users \
    && chmod 644 /etc/gitweb.conf \
    && chmod 755 /home/$HCLTXAPP_USER/start.sh

# Set user name to run container
USER $HCLTXAPP_USER

#Below arg are used by label command.
ARG MANIFEST

#Provides build and source information.
#Use docker inspect to view.
LABEL com.hcl.tx.manifest=$MANIFEST
LABEL vendor=vendor1 cnf=CNF-Service-1

CMD /./home/$HCLTXAPP_USER/start.sh
