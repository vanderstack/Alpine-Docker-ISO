# Alpine Docker ISO
This repository allows for building an Alpine Linux live ISO with docker preinstalled.

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

### SSH
SSH is disabled for the root account.  
SSH is enabled for the account `vanderstack`.  
The SSH password must be configured as a repository secret named `SSH_PASSWORD` prior to building the ISO.

### Docker-Compose
Docker automatically runs on startup.  
Once Docker is available `docker-compose.yml` is pulled from `vanderstack/vanderstack-docker-server/` to configure and run docker-compose.
