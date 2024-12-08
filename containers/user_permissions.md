# User Permssions

Instructions to follow the best practices suggested by linuxserver.io by using separate users and groups to maintain separation between unrelated containers.

## PUID and PGID

> Using the PUID and PGID allows our containers to map the container's internal user to a user on the host machine. All of our containers use this method of user mapping and should be applied accordingly.

so, if I want a particular container to have access to a given user, I need to make the user first on the host machine with the appropriate given permissions.  This will be very useful to configure my media server with rw permissions for only a handful of containers. (Currently, I have the media server with chmod 777 settings, which is not the most ideal because anyone can read write and execute any of the files!)

## creating and managing groups

Following basics outlined [here](https://www.redhat.com/sysadmin/linux-user-group-management)  I will be adding the required users and groups for my Jellyfin server.  Any service that need to read and write to the media server will be added to the `media` group created by

```bash
sudo groupadd media
```

let's change the group GID so that we don't get conflicts with newly created users.  When a user is created, the system will add them to a group that has the same GID as the UID, so let's bump the `media` GID to avoid conflicts

```bash
sudo groupmod -g 10001 media
```
(it was 1001 on my machine)

adding users to the group is as easy as

```bash
sudo usermod -g media <user>
```

special consideration is needed for the primary user.  In this case, I will be added to the secondary group, which will allow me to access `media` files with the default `media` settings.  However, the rest of the `media` group will not have access to other files created by me

```bash
sudo usermod -aG media brendan
```

we can verify the addition with

```bash
$ tail /etc/group
pulse-access:x:118:
scanner:x:119:saned
saned:x:120:
vnc:x:992:
colord:x:121:
brendan:x:1000:
sambashare:x:991:
docker:x:989:brendan
media:x:10001:brendan
```

creating new users and adding them to the `media` group

```bash
sudo useradd jellyfin
sudo usermod -g media jellyfin
```
