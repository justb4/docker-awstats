#!/bin/bash

# Generate complete awstats confs in /etc/awstats and setup cron schedule

echo "START aw-setup"

echo "Running one-time provisioning"
for f in /aw-setup.d/*
do
	case "$f" in
	  */*.sh) echo "$0: running $f" && . "$f" ;;
	esac
done

INDEX_HTML=/var/www/index.html

pushd ${AWSTATS_SITES_DIR}
	echo "<h3>AWStats Sites</h3>" > ${INDEX_HTML}

	# Env substitution sites
	SITE_ENVS=$(ls *.env)
	for SITE_ENV in ${SITE_ENVS}
	do
		# https://stackoverflow.com/questions/19482123/extract-part-of-a-string-using-bash-cut-split/19482947
		SITE=${SITE_ENV%%.env}

		echo "Setup ${SITE} with ${SITE_ENV}"
		echo "<br><a href=\"${AWSTATS_PATH_PREFIX}/aws/awstats.pl?config=${SITE}\">${SITE}</a>" >> ${INDEX_HTML}

		# generate AWStats config for SITE
		source ${SITE_ENV}
		envsubst < ${AWSTATS_CONF_DIR}/awstats_env.conf > ${AWSTATS_CONF_DIR}/awstats.${SITE}.conf
	done

	# Complete conf sites
	SITE_CONFS=$(ls *.conf)
	for SITE_CONF in ${SITE_CONFS}
	do
		# https://stackoverflow.com/questions/19482123/extract-part-of-a-string-using-bash-cut-split/19482947
		SITE=${SITE_CONF%%.conf}

		echo "Setup ${SITE} with ${SITE_CONF}"
		echo "<br><a href=\"${AWSTATS_PATH_PREFIX}/aws/awstats.pl?config=${SITE}\">${SITE}</a>" >> ${INDEX_HTML}

		# copy config for SITE
		cp ${SITE_CONF} ${AWSTATS_CONF_DIR}/awstats.${SITE}.conf
	done

popd

echo "Setup cron schedule: ${AWSTATS_CRON_SCHEDULE}"
envsubst < ${AWSTATS_CONF_DIR}/awstats_env.cron > ${AWSTATS_CONF_DIR}/cronfile
crontab ${AWSTATS_CONF_DIR}/cronfile
rm /etc/cron.d/awstats
crontab -l

echo "STOP aw-setup: index.html="
cat ${INDEX_HTML}
sleep 3
exit 0
