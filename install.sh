#!/bin/bash

apt -y update
apt -y --no-install-recommends install curl jq unzip lib32gcc-s1 ca-certificates

VERSION="${VERSION:-latest}"
MATCH="open.mp-win-x86"

mkdir -p /mnt/server/temp
cd /mnt/server/temp || exit

RELEASE_JSON=$(curl -s https://api.github.com/repos/openmultiplayer/open.mp/releases/latest)
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[].browser_download_url' | grep -i "$MATCH")

echo "Downloading OpenMP from: $DOWNLOAD_URL"
curl -sSL -o openmp.zip "$DOWNLOAD_URL"

unzip -o openmp.zip -d /mnt/server/temp

if [ -d /mnt/server/temp/Server ]; then
  mv /mnt/server/temp/Server/* /mnt/server/
fi
rm -rf /mnt/server/temp

cd /mnt/server || exit

if [ ! -f config.json ]; then
  echo "Downloading default config.json"
  curl -sSL https://raw.githubusercontent.com/aruliazmi/open-mp/refs/heads/master/config.json -o config.json
else
  echo "Using existing config.json"
fi

chown -R root:root /mnt
export HOME=/mnt/server

echo "-----------------------------------------"
echo "OpenMP installation completed."
echo "Eggs Created By Aruli Azmi."
echo "-----------------------------------------"
