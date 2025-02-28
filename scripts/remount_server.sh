# /usr/bin/bash

# when the server gets disconnected all of the containers related to the server need to be restarted to pick up the correct permissions

# first remount the external drive, probably should be more specific, but this works for now and I'm feeling lazy
sudo mount -a

# this will fail I think if the containers aren't already running, but the should be running
docker restart qbittorrent
docker restart radarr
docker restart plex
docker restart jellyfin
docker restart sonarr
