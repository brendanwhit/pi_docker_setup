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

## mounting external disk with new permissions

My media server will live on an external harddrive that will be accessed via the Raspberry Pi.  

NOTE: the external hard drive NEEDS external power.  Without it external power the draw is too high and results in unwatchable amounts of buffering when trying to watch shows and movies.  [This powered USB hub](https://www.amazon.com/dp/B0C2Z8KCF1) worked for me.

`UUID=062e9ce2-2c27-4180-85a5-3cc9003de379 /server/media_server ext4 defaults 0 0`

there is no way to specify user and group at time of boot with ext4 drives.  However, according to [this thread](https://superuser.com/questions/519824/mounting-ext4-drive-with-specified-user-permission) changing the permissions on the mount point will change the permissions of the mounted drive permanently.

### finding device UUID

super easy just run

```bash
$ lsblk -f
NAME        FSTYPE FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sda                                                                                 
└─sda1      ext4   1.0          062e9ce2-2c27-4180-85a5-3cc9003de379                
mmcblk0                                                                             
├─mmcblk0p1 vfat   FAT32 bootfs 50C8-AEAE                             435.2M    15% /boot/firmware
└─mmcblk0p2 ext4   1.0   rootfs fc7a1f9e-4967-4f41-a1f5-1b5927e6c5f9  106.7G     4% /
```

### changing permissions on the mountpoint

use `chown` and `chmod` to change the permissions of the external mount

```bash
$ sudo chown jellyfin:media /jellyfin
$ ls -lah /
drwxr-xr-x   3 jellyfin media 4.0K May 30 15:09 jellyfin
$ sudo chmod 774 /jellyfin
$ ls -lah /
drwxrwxr--   3 jellyfin media 4.0K May 30 15:09 jellyfin
```

I've used fairly explicit permissions for the external drive since there will be a number of docker containers that will be able to write to it.

`rwx` - permissions for `jellyfin`, meaning the jellyfin user (in this case the docker container) can read, write, and execute files in the directory

`rwx` - permissions for the group `media`, meaning the members of the group are allowed to read, write, and execute them

**Note: execution rights are needed for directories so that users and group members can create new files in them**

`r--` - permissions for others, meaning they can only read files from the directory

### testing permissions

```bash
brendan@themistress:~ $ sudo chmod -R 771 /jellyfin
brendan@themistress:~ $ ls -lah /
drwxrwx--x   4 jellyfin media 4.0K May 30 16:13 jellyfin
brendan@themistress:~ $ ls -lah /jellyfin
total 28K
drwxrwx---  4 jellyfin media 4.0K May 30 16:13 .
drwxr-xr-x 21 root     root  4.0K May 29 11:37 ..
drwxrwx---  2 root     root   16K May 30 15:09 lost+found
drwxrwx---  2 root     root  4.0K May 30 16:13 staging
brendan@themistress:~ $ touch /jellyfin/brendan.test
brendan@themistress:~ $ ls -lah /jellyfin
total 28K
drwxrwx---  4 jellyfin media 4.0K May 30 16:17 .
drwxr-xr-x 21 root     root  4.0K May 29 11:37 ..
-rw-r--r--  1 brendan  media    0 May 30 16:17 brendan.test
drwxrwx---  2 root     root   16K May 30 15:09 lost+found
drwxrwx---  2 root     root  4.0K May 30 16:13 staging
brendan@themistress:~ $ su - qbittorrent 
qbittorrent@themistress:/home/brendan$ touch /jellyfin/qbittorrent.test
qbittorrent@themistress:/home/brendan$ ls -lah /jellyfin
total 28K
drwxrwx---  4 jellyfin    media 4.0K May 30 16:18 .
drwxr-xr-x 21 root        root  4.0K May 29 11:37 ..
-rw-r--r--  1 brendan     media    0 May 30 16:17 brendan.test
drwxrwx---  2 root        root   16K May 30 15:09 lost+found
-rw-r--r--  1 qbittorrent media    0 May 30 16:18 qbittorrent.test
drwxrwx---  2 root        root  4.0K May 30 16:13 staging
```

### testing that changes persist through mounting

```bash
$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sdc           8:32   0 931.5G  0 disk 
└─sdc1        8:33   0 931.5G  0 part /jellyfin
$ sudo umount -l /dev/sdc1
$ ls -lah /
# reverts to previous permissions of the mountpoint
drwxrwxrwx   5 brendan brendan 128K May 30 10:25 jellyfin
$ sudo mount -a
$ ls -lah /
drwxrw-r--   3 jellyfin media 4.0K May 30 15:09 jellyfin
```

### further reading about permissions

https://www.opensourceforu.com/2016/01/secure-a-linux-box-through-the-right-file-permissions/

https://unix.stackexchange.com/questions/684122/what-permissions-on-a-file-or-directory-are-needed-to-cp-mv-and-rename-or-make
