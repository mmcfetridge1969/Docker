ARR stack with Gluetun VPN container

###############################################################################################
DIRECTORY SETUP

data
├── books
├── downloads
│   ├── qbittorrent
│   │   ├── completed
│   │   ├── incomplete
│   │   └── torrents
│   └── nzbget
│       ├── completed
│       ├── intermediate
│       ├── nzb
│       ├── queue
│       └── tmp
├── movies
├── music
├── shows
└── youtube
└── books

Run within the /data directory.
mkdir -p downloads/qbittorrent/{completed,incomplete,torrents} && mkdir -p downloads/nzbget/{completed,intermediate,nzb,queue,tmp}

#################################################################################################

SET PERMISSIONS

sudo chown -R 1000:1000 data/
sudo chown -R 1000:1000 docker/
sudo chown -R 1000:1000 /media/arr
sudo chown -R $USER:$USER /data
sudo chmod -R a=,a+rX,u+w,g+w data/

##################################################################################################

First configure the qBittorrent service because its using temporary password only:<br />

**qBittorrent:**<br />
First - check what qbittorrent temporary password is to be able to log on:<br />
`docker logs qbittorrent`<br />
You will see in the logs something like:<br />
*The WebUI administrator username is: admin<br />
The WebUI administrator password was not set. A temporary password is provided for this session: <your-password-will-be-here>* <br />
Now you can go to URL:<br />
http://localhost:8080<br />
and log on using details provided in container logs.<br />
Go to Tools - Options - WebUI - change the user and password and tick 'bypass authentication for clients on localhost' .<br />

Then configure Prowlarr service (each of these services will require to set up user/pass):<br />

**Prowlarr:**<br />
http://localhost:9696<br />
Go to Settings - Download Clients - `+` symbol - Add download client - choose qBittorrent (unless you decided touse different download client)<br />
Put the port id matching the WebUI in docker-compose for qBittorrent (default is 8080) and username and password that you configured for qBittorrent in previous step<br />
Host - leave 'localhost' setting as it is<br />

**Sonarr:**<br />
http://localhost:8989<br />
Go to Settings - Media Management - Add Root Folder - set your root folder to whatever is on the right side of the colon in 'volumes' setting for Sonarr.<br />
If its '/media/arr/sonarr/tvseries:/tv' then set it to '/tv' as your root folder<br />
If its '/media/arr/sonarr/tvseries:/data/TVSeries then set root folder to /data/TVSeries' ( that might differ from image to image so double check)<br /> 
Go to Settings - Download Clients - click `+` symbol - choose qBittorrent and repeat the steps from Prowlarr.<br />
Go to Settings - General - scroll down to API key - copy - go to Prowlarr - Settings - Apps -click '+' - Sonarr - paste  API key.<br />

**Radarr:**<br />
http://localhost:7878<br />
Go to Settings - Media Management - Add Root Folder - set  /data/movies as your root folder <br />
Then Settings- Download clients - click 'plus' symbol, choose qBittorrent etc - basically same steps as for Sonarr<br />
Settings - General - scroll down to API key - copy - go to Prowlarr - add same way as in sonarr<br />
Settings - General - switch to 'show advanced'- Backups - choose /data/Backup folder <br />

**Lidarr:**<br />
http://localhost:8686<br />
Follow the same steps for Lidarr and Readarr as for above applications.<br />

**Readarr:**<br />
http://localhost:8787<br />

Now go back to Prowlarr and click 'Indexers at the top right, click 'Add indexer' - search for sth like 'rarbg' or 'yts' etc then test - save<br />
Then click 'Sync App Indexers  icon (next to 'Add indexer')<br />
If you go to Settings - Apps - you should see green 'Full sync' next to each application.<br />
Arr stack completed - you can now 'add movie' in radarr or 'add series' in sonarr etc and click 'search all' or 'search monitored' - that will trigger the download process.<br />

**Jellyfin:**<br />
http://localhost:8096<br />
If you run `docker-compose up` and have something running on port 1900 -  its most possibly rygel service, run:<br />
`sudo apt-get remove rygel` and run the `sudo docker-compose up -d` again.<br />
Then add media library in Jellyfin  matching folders configured in docker-compose.yml file, so in Jellyfin you should see them as: <br />
/data/movies <br />
/data/tvshows <br />

Note that this also might depend on the image, you basically match the right side of the config in Jellyfin's 'volume' configuration. <br />
If the volume configuration looks like that: <br />
```
    volumes:
      - /media/arr/sonarr/tvseries:/data/tvshows
      - /media/arr/radarr/movies:/data/movies
```
then on the container you match that right side from the colon ( /data/movies, /data/tvshows etc )<br />


Gluetun should be already configured.<br />
