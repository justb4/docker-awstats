# Test 
Example for testing and guidance for setting up `justb4/awstats`.

* under [sites](sites) are the .env and or .conf files for awstats config
* logfiles under [log](log)
* the dir [awstats](awstats) will contain the `awstats` generated datafiles

These dirs are volume-mapped within a [docker-compose.yml](docker-compose.yml) file.
 
## Usage

* Start with `docker-compose up`  or `./start.sh`
* wait at least 15 mins for first stats to be run
* OR if impatient go into Docker container and run:
```
docker exec -it awstats /bin/bash
# in container
aw-update.sh

```
* browse to http://localhost:8081

