FROM httpd:2.4.41

# FROM httpd:2.4.41-alpine
# Problem: https://gitlab.alpinelinux.org/alpine/aports/issues/10792
# apache2-mod-perl missing in Alpine recent, cannot use httpd:2.4.*-alpine and geoip not avail on alpine!

# Credits to Patrick Braune for providing first versions
LABEL original_developer="Patrick Braune <https://github.com/pabra>" \
	maintainer="Just van den Broecke <justb4@gmail.com>"

ARG GEOIP_PACKAGES="libgeo-ipfree-perl libnet-ip-perl"

RUN \
	apt-get update \
	&& apt-get -yy install awstats gettext-base libapache2-mod-perl2 ${GEOIP_PACKAGES} supervisor cron \
	&& echo 'Include conf/awstats_httpd.conf' >> /usr/local/apache2/conf/httpd.conf  \
	&& mkdir /var/www && mv /usr/share/awstats/icon /var/www/icons && chown -R www-data:www-data /var/www \
    && apt-get clean && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Configurations, some are templates to be substituted with env vars
ADD confs/awstats_env.conf confs/awstats_env.cron /etc/awstats/
ADD confs/awstats_httpd.conf /usr/local/apache2/conf/
ADD confs/supervisord.conf /etc/
ADD scripts/*.sh  /usr/local/bin/

# Default env vars
ENV \
	AWSTATS_CONF_DIR="/etc/awstats" \
	AWSTATS_SITES_DIR="/etc/awstats/sites" \
	AWSTATS_CRON_SCHEDULE="*/15 * * * *" \
	AWSTATS_PATH_PREFIX="" \
	AWSTATS_CONF_LOGFILE="/var/local/log/access.log" \
	AWSTATS_CONF_LOGFORMAT="%host %other %logname %time1 %methodurl %code %bytesd %refererquot %uaquot" \
	AWSTATS_CONF_SITEDOMAIN="mydomain.com" \
	AWSTATS_CONF_HOSTALIASES="localhost 127.0.0.1 REGEX[^.*$]" \
	AWSTATS_CONF_DEBUGMESSAGES="0" \
	AWSTATS_CONF_DNSLOOKUP="1"

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
