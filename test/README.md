# Test 
Example for testing and guidance for setting up `justb4/awstats`.

* under [sites](sites) are the .env and or .conf files for awstats config
* logfiles under [log](log)
* the dir [awstats](awstats) will contain the `awstats` generated datafiles

These dirs are volume-mapped within a [docker-compose.yml](docker-compose.yml) file.
 
## Usage

* Start with `docker-compose up`
* wait at least 2 mins for first stats to be run
* browse to http://localhost:8081

