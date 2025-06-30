#!/bin/bash
set -e

echo "==============================================="
echo "[INSTALL] Mulai instalasi OpenMP di Wine (mono-ubuntu)"
echo "==============================================="

echo "[INSTALL] Update & install dependencies..."
dpkg --add-architecture i386
apt update
apt install -y --no-install-recommends \
  curl jq unzip ca-certificates cabextract \
  lib32gcc-s1 lib32stdc++6 winbind gnupg \
  wine wine32 winetricks xvfb

export HOME=/mnt/server
export WINEPREFIX=/mnt/server/.wine

echo "[INSTALL] Memberi akses ke user www-data..."
chown -R www-data:www-data /mnt/server

echo "[INSTALL] Inisialisasi Wine (www-data)..."
su -s /bin/bash www-data -c "xvfb-run --auto-servernum --server-args='-screen 0 1024x768x16' wineboot"

mkdir -p /mnt/server/temp
cd /mnt/server/temp || exit 1

VERSION="${VERSION:-latest}"
MATCH="open.mp-win-x86"

echo "[INSTALL] Mengambil data rilis OpenMP..."
RELEASE_JSON=$(curl -s https://api.github.com/repos/openmultiplayer/open.mp/releases/latest)
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[].browser_download_url' | grep -i "$MATCH")

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "[ERROR] Tidak dapat menemukan URL unduhan OpenMP."
  exit 1
fi

echo "[INSTALL] Mengunduh dari: $DOWNLOAD_URL"
curl -sSL -o openmp.zip "$DOWNLOAD_URL"
unzip -o openmp.zip -d /mnt/server/temp

if [ -d /mnt/server/temp/Server ]; then
  mv /mnt/server/temp/Server/* /mnt/server/
else
  mv /mnt/server/temp/* /mnt/server/
fi
rm -rf /mnt/server/temp

cd /mnt/server || exit 1

if [ ! -f config.json ]; then
  echo "[INSTALL] Mengunduh default config.json..."
  curl -sSL https://raw.githubusercontent.com/aruliazmi/open-mp/master/config.json -o config.json
else
  echo "[INSTALL] config.json sudah ada, dilewati."
fi

if [ ! -f "./omp-server.exe" ]; then
  echo "[ERROR] File omp-server.exe tidak ditemukan setelah instalasi."
  exit 1
fi

chown -R www-data:www-data /mnt

echo "==============================================="
echo "✅ Instalasi OpenMP selesai (mono-ubuntu)"
echo "Egg by Aruli Azmi"
echo "==============================================="
