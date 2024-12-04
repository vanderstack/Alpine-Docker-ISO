# Alpine Docker ISO
Alpine Linux with docker preinstalled (Live Image)

### Building an ISO
Pushing a new tag triggers GitHub actions to build a new ISO and attach it to a draft release.

### Managing repository ISOs
Actions exist to List Github Artifacts or Delete GitHub Artifact by ID.

### Root account
The root account does not have a password. To set it log in as root and type `passwd`.

### Networking
DHCP is enabled on eth0.  
To configure other interfaces run `setup-interfaces` and then `service networking restart` to apply settings.

### SSH
By default, it is not possible to log into the root account via ssh: use account `vanderstack`.

### Docker-Compose
On startup docker is automatically started
On startup docker-compose.yml is pulled from VanderStack/vanderstack-docker-server/ and automatically started once docker is available  
