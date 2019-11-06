README
======

All-in-one [Awstats](http://www.awstats.org) Docker Image for scheduled log-processing on multiple domains with minimal config, accessible 
via built-in webpage.

Features
--------

* multiple `awstats` configs, i.e. (web)sites
* configure sites with an `.env` file with a few variables or with a complete `awstats` conf files
* single [aw-update.sh](scripts/aw-update.sh) script that updates stats for all configured sites
* internally runs scheduled `awstats` (via `cron`) within the Docker container
* GeoIP applied (i.e. see countries etc of visitors)
* self-hosted via embedded Apache2 HTTP server 
* landing HTML page for all configured sites
* configurable `subpath` (prefix) for running behind reverse proxy
* easy run with [docker-compose](test/docker-compose.yml)

The aim was to make this image as self-contained as possible with minimal host-dependencies.

Credits
-------

This Docker setup is based on work from:
https://github.com/pabra/docker_awstats.

That image runs with Alpine Linux. Due to some of the more advanced 
features I used, like GeoIP, bash-scripts, it became too complex (at least for me!) to use Alpine Linux
and extend that good work. Also I wanted to reduce host-dependency, e.g. needing `cron` from host.
Also for deploy in e.g. `Kubernetes`.

I would be happy if someone manages to migrate `justb4/awstats` to Alpine, preferably
extending https://github.com/pabra/docker_awstats !

Quickstart
----------

See the [test](test) directory for a complete example.

Basically `justb4/awstats` needs to find files within the following (internal) dirs:

* under `/etc/awstats/sites/` per-site file configs, either `.env` (vars) or complete `awstats` conf files
* under `/var/local/log` the log files, although you can determine log-locations/filenames in your `.env` or `.conf` file

As `awstats` keeps its data onder `/var/lib/awstats` you will need to make that dir persistent over restarts,
as a Docker Volume either mapped from a local dir on you host or an explicit Docker Volume.

Awstats Documentation
---------------------

* All on [awstats config](http://www.awstats.org/docs/awstats_config.html)
* https://blogging.dragon.org.uk/installing-awstats-on-ubuntu-16-04-lts/

Design
======

The intention is to have this Docker image as self-contained as possible in order to
avoid host-bound/specific actions and tooling, in particular log processing via 
host-based `cron`, we may even apply `logrotate` later. Also allow for multiple domains with minimal config.

Further design choices:

* schedule `awstats` processing (via `cron`)
* allow for multiple domains
* generate a landing HTML page with links to stats of all domains
* allow for minimal config within an `.env` file (expand with `envsubst` into template `.conf`)
* allow full Awstats `.conf` file as well
* have GeoIP reverse IP lookup, enabled (may need more advanced/detailed upgrade to...)
* configurable `subpath` (prefix) for running behind reverse proxy via `AWSTATS_PATH_PREFIX=` env var
* make it easy run with [docker-compose](test/docker-compose.yml)
 
A `debian-slim` Docker Image ((`buster` version) is used as base image. 
(I'd love to use Alpine, but it became too complicated
with the above features, input welcome!). 
The entry program is `supervisord` that will run a [setup program once](scripts/aw-setup.sh), `apache2` webserver daemon
(for the landing page and logstats), and `cron` for Awstats processing.
 
Advanced
========

Analyze old log files
---------------------

Awstats only processes lines in log files that are newer than the newest already
known line.  
This means you cannot analyze older log files later. Start with oldest ones first.
You may need to delete already processed data by `rm /var/lib/awstats/*`

Example sketch of bash-script to process old Apache2 logfiles partly gzipped:

```bash
#!/bin/bash
#
# Run the app
# 
#
# Example gzipped log files from mydomain.com-access.log.2 up to mydomain.com-access.log.60
LOGDIR="/var/local/log"
LOGNAME="access.log"
END=60

# Loop backwards 60,59,...2.
for i in $(seq $END -1 2)
do
  logFile="${LOGDIR}/${LOGNAME}.${i}"
  echo "i=${i} logFile=${logFile}"
  docker exec -it awstats gunzip ${logFile}.gz
  docker exec -it awstats awstats -config=mydomain.com -update -LogFile="${logFile}"
  docker exec -it awstats gzip ${logFile}
done

# Non-zipped remaining files
docker exec -it awstats awstats -config=mydomain.com -update -LogFile="${LOGDIR}/${LOGNAME}.1"
docker exec -it awstats awstats -config=mydomain.com -update -LogFile="${LOGDIR}/${LOGNAME}"


```
