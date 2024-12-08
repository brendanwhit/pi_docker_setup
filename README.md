# installing docker

first need to install docker engine. [Full instructions here](https://docs.docker.com/engine/install/debian/)

just to be safe make sure older versions are uninstalled, there shouldn't be any on a fresh install of Pi

```bash
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

then install using `apt`.  First step is adding the Docker repositories.

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

`curl` and `ca-certificates` should already be installed, but leaving them in the above command just in case. Then install everything including the `compose-plugin` from the docker repos.

## changing docker permissions to run without sudo

[full instructions](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)

three step process for the PI

1. Add your user to the docker group.

`$ sudo usermod -aG docker $USER`

2. Log in to the new docker group (to avoid having to log out / log in again; but if not enough, try to reboot):

`$ newgrp docker`

3. Check if docker can be run without root

`$ docker run hello-world`
