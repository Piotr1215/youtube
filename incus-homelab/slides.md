---
theme: ./theme.json  
author: Cloud-Native Corner  
date: MMMM dd, YYYY  
paging: Slide %d / %d  
---

# Docker on vm using incus

```bash
~~~./intro.sh

~~~
```

---

## Introduction

- 🏠 **Why Use a Home Lab?**
- 🛠️ **Understanding Virtualization**
- 📚 **Setup Docker on a VM**

---

## Why Use Incus?

- 🚀 **Efficient Resource Management**: Lightweight virtualization (app/system containers and vms)
- 🛡️ **Security Features**: Unprivileged containers, network isolation, resource restrictions.
- 🌐 **Cross-Platform Support**: Works on Linux, macOS (via Colima), and Windows (via WSL).


---

## Setting Up an Ubuntu VM on Incus

https://linuxcontainers.org/incus/docs/main/

```bash
# Launch the Ubuntu VM
incus launch images:ubuntu/22.04 ubuntu --vm

# Check VM Status
incus list

# Access the VM
incus exec ubuntu -- bash

# Manage VM Configuration
incus config set ubuntu limits.cpu=2 limits.memory=2GB

# Configure networking
incus config device add ubuntu eth0 nic network=incusbr0
```

---

## Task 1 launch desktop environment

Attach console to the running vm instance

```bash
incus console ubuntu --type=vga
```

---

## Task 2 install docker

https://docs.docker.com/engine/install/ubuntu/

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---
## Setup Docker Connectivity

https://docs.docker.com/engine/daemon/remote-access/

```bash
sudo systemctl edit docker.service
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock
```

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker.service
```

> This makes port `<VM-IP>:2375` accessible to docker client from the host

---

## Configure firewall rules

If using `ufw`

```bash
sudo vim `/etc/ufw/ufw.conf` and set `DEFAULT_FORWARD_POLICY="ACCEPT"
```

---
## Bonus: use direnv for remote docker connection

Create `.envrc` file in a folder and add

```bash
export DIP=$(incus exec ubuntu -- hostname -I | awk '{print $1}')
export DIP_URL="http://${DIP}"

export DOCKER_HOST=tcp://$DIP:2375
```

After `direnv allow` every time you enter this directory, the docker client
will point to the docker host vm

---

## Create the container

```bash
docker run -d -p 8080:80 docker/welcome-to-docker
```

---

## Test the setup

```bash
open $DIP_URL:8080
```

---

```bash
../thats_all_folks
```
