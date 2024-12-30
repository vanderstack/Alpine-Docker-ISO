# Alpine Docker ISO
This repository allows for building an Alpine Linux live ISO with docker preinstalled.

### Purpose
As I was prototyping my stack I wanted to host my workloads within virtualbox for portabiity and ease of setup and administration.  
My stack has deprecated this approach in favor of using proxmox to host an alpine container with docker compose and portainer.  

### Repository Secrets
The repository secret named `SSH_PASSWORD` must be configured prior to building the ISO.
This password will also be used to mount the network share for persistent storage.

### Building an ISO
Use the GitHub action `Publish ISO` to build a new ISO. The version of Alpine Linux to be used must be provided as a parameter.  
The latest version which has been confirmed to work is 3.20.  
Retrieve the ISO using the link provided in the step `Upload Files`.  
Delete the ISO once downloaded.

### Managing repository ISOs
Actions exist to Publish ISO, List Github Artifacts, and Delete GitHub Artifact by ID.

### Root account
The root account does not have a password. To set it log in as root and type `passwd`.

### Networking
DHCP is enabled on eth0.  
To configure other interfaces run `setup-interfaces` and then `service networking restart` to apply settings.
The HOSTNAME `vanderstack-docker` is automatically mapped to the IP Address of eth0

### SSH
SSH is disabled for the root account.  
SSH is enabled for the account `vanderstack`.  

### Network Storage
The network share `//Z-GAMING/vanderstack-share$` is mounted to `/mnt/vandertack-share`

### Docker-Compose
Docker automatically runs on startup.  
Once Docker is available `docker-compose.yml` is pulled from `vanderstack/vanderstack-docker-server/` to configure and run docker-compose.
