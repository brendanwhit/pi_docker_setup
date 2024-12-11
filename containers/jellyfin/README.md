# jellyfin

jellyfin was super straightforward follwing [docs](https://docs.linuxserver.io/images/docker-jellyfin/)

the only major change I made was setting `network_mode: host`, which didn't require any portforwarding

## using tailscale

I decided to add `tailscale` to the Docker container so that I can access the server outside of the home.

I followed [this great tutorial](https://tailscale.com/kb/1282/docker) with a few tweaks here and there.

I could only get local network and remote access using `network_mode: host` on the tailscale container, so that is what I went with.

Once the docker container was running successfully, I had to turn on remote access for the server.

Navigate to `Dashboard > Networking` and scroll down to `Remote Access Settings` on Jellyfin. Set the `Remote IP address filter mode` to `Blacklist` to allow for easier Tailscale connections.

## accessing remotely

Accessing remotely is a breeze (maybe a stiff breeze, but easy nonetheless).
1. First download Tailscale on any device using the node sharing link.
2. Download Jellyfin
3. Copy the MagicDNS address from `tailscale-jellyfin`
4. Enter that address as the server address in Jellyfin
5. Create an account and you are in!

