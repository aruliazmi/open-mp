#!/bin/bash
apt -y update
apt -y --no-install-recommends install curl unzip lib32gcc1 ca-certificates

cd /tmp
curl -sSL -o openmp.zip https://github.com/openmultiplayer/open.mp/releases/latest/download/open.mp-win-x86.zip

mkdir -p /mnt/server
unzip -o openmp.zip -d /mnt/server/tmp

mv /mnt/server/tmp/*/* /mnt/server/

rm -rf /mnt/server/tmp

cd /mnt/server
chown -R root:root /mnt
export HOME=/mnt/server
