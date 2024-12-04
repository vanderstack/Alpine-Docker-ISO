#!/bin/sh -e

alpinelinux="v3.20.3"
version="${alpinelinux%.*}"

HOSTNAME="vanderstack-docker-server"

cleanup() {
	rm -rf "$tmp"
}

makefile() {
	OWNER="$1"
	PERMS="$2"
	FILENAME="$3"
	cat > "$FILENAME"
	chown "$OWNER" "$FILENAME"
	chmod "$PERMS" "$FILENAME"
}

rc_add() {
	mkdir -p "$tmp"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

mkdir -p "$tmp"/etc
makefile root:root 0644 "$tmp"/etc/hostname <<EOF
$HOSTNAME
EOF

mkdir -p "$tmp"/etc/network
makefile root:root 0644 "$tmp"/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

mkdir -p "$tmp"/etc/apk
makefile root:root 0644 "$tmp"/etc/apk/world <<EOF
alpine-base
bash-completion
coreutils
docker
docker-bash-completion
docker-cli-compose
findutils
openssh
procps
readline
sed
sudo
util-linux
EOF

makefile root:root 0644 "$tmp"/etc/apk/repositories <<EOF
https://dl-cdn.alpinelinux.org/alpine/${version}/main
https://dl-cdn.alpinelinux.org/alpine/${version}/community
EOF

mkdir -p "$tmp"/etc/local.d
makefile root:root 0744 "$tmp"/etc/local.d/set_bash.start <<EOF
#!/bin/ash
sed -i 's|root:/bin/ash|root:/bin/bash|' /etc/passwd
EOF

makefile root:root 0744 "$tmp"/etc/local.d/add_user.start <<EOF
#!/bin/ash
user="vanderstack"
echo -e "\$user\n\$SSHPASSWORD" | adduser \$user -s /bin/bash
mkdir /etc/sudoers.d
echo "\$user ALL=(ALL) ALL" > /etc/sudoers.d/\$user && chmod 0440 /etc/sudoers.d/\$user
EOF

mkdir -p "$tmp"/usr/bin
makefile root:root 0755 "$tmp"/usr/bin/hello <<EOF
#!/bin/sh

echo "Hello VanderStack, welcome to your docker VM!"
echo "To view running containers log into the shell and run the command:"
echo "docker ps"
EOF

makefile root:root 0755 "$tmp"/usr/bin/compose <<EOF
#!/bin/sh

# Variables
COMPOSE_URL="https://github.com/vanderstack/vanderstack-docker-server/raw/main/docker-compose.yml"
COMPOSE_DIR="/tmp/docker"

# Ensure Docker is running
echo "Waiting for Docker to start..."
while ! docker info >/dev/null 2>&1; do
    sleep 2
done
echo "Docker is running."

# Create directory for docker-compose file
echo "Creating directory for docker-compose file at \$COMPOSE_DIR ..."
mkdir -p "\$COMPOSE_DIR"
cd "\$COMPOSE_DIR" || exit 1

# Download the docker-compose.yml file
echo "Downloading docker-compose.yml from \$COMPOSE_URL ..."
if ! wget -O docker-compose.yml "\$COMPOSE_URL"; then
    echo "Error: Failed to download docker-compose.yml from \$COMPOSE_URL."
    exit 1
fi

# Start services with docker-compose
echo "Starting services with docker-compose..."
if ! docker-compose up -d; then
    echo "Error: Failed to start services with docker-compose."
    exit 1
fi

echo "Services started successfully."
EOF

# configure OpenRC init scripts for hello and compose so that rc_add works correctly to automatically start them
mkdir -p "$tmp"/etc/init.d
# Init script for compose
makefile root:root 0744 "$tmp"/etc/init.d/compose <<EOF
#!/sbin/openrc-run

description="Compose script for running Docker Compose workloads"
command="/usr/bin/compose"
command_background="yes"
pidfile="/run/compose.pid"
EOF

# Init script for hello
makefile root:root 0744 "$tmp"/etc/init.d/hello <<EOF
#!/sbin/openrc-run

description="Hello world script"
command="/usr/bin/hello"
EOF

rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit

rc_add hwclock boot
rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add syslog boot
rc_add networking boot
rc_add local boot

rc_add docker default
rc_add compose default
rc_add sshd default
rc_add hello default

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown

tar -c -C "$tmp" etc usr| gzip -9n > $HOSTNAME.apkovl.tar.gz
