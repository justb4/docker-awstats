# Sites Configs
In this dir or a dir mounted as Docker Volume to `/etc/awstats/sites` within Container two types of file
can be placed:

* `.env` files, containing only several variables for quick config substituted in [awstats_env.conf](../awstats_env.conf)
* complete `.conf` files, containing a complete `awstats` `CONFIGURE FILE 7.3` like [geotracing.com.conf](geotracing.com.conf)

In an `.env` file the following vars can be specified, as example below:

```
AWSTATS_CONF_LOGFILE=/var/local/log/map5.nl/map5.nl-access.log
AWSTATS_CONF_LOGFORMAT="%host %other %logname %time1 %methodurl %code %bytesd %refererquot %uaquot"
AWSTATS_CONF_SITEDOMAIN=map5.nl
AWSTATS_CONF_DNSLOOKUP=1
AWSTATS_CONF_DEBUGMESSAGES=1
AWSTATS_CONF_HOSTALIASES=www.map5.nl

``` 

## Notes

* note the use of [Traefik](https://traefik.io/) logs, these have their own logline format
* using `%virtualnamequot` within the conf/env files stats for multiple virtual hosts/subpaths can be extracted from a single logfile

