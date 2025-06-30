#!/bin/bash

# Update dan install dependensi dasar
apt -y update
apt -y --no-install-recommends install curl jq unzip ca-certificates \
    lib32gcc-s1 lib32stdc++6 winbind xvfb xauth wine64 wine32 winetricks

# Setup environment
export WINEPREFIX=/mnt/server/.wine
mkdir -p /mnt/server/temp
cd /mnt/server/temp || exit

# Ambil versi OpenMP
VERSION="${VERSION:-latest}"
MATCH="open.mp-win-x86"

echo "[INSTALL] Mengambil informasi rilis OpenMP..."
RELEASE_JSON=$(curl -s https://api.github.com/repos/openmultiplayer/open.mp/releases/latest)
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | jq -r '.assets[].browser_download_url' | grep -i "$MATCH")

echo "[INSTALL] Mendownload OpenMP dari: $DOWNLOAD_URL"
curl -sSL -o openmp.zip "$DOWNLOAD_URL"

echo "[INSTALL] Mengekstrak openmp.zip..."
unzip -o openmp.zip -d /mnt/server/temp

# Pindahkan ke direktori utama
if [ -d /mnt/server/temp/Server ]; then
  mv /mnt/server/temp/Server/* /mnt/server/
else
  mv /mnt/server/temp/* /mnt/server/
fi
rm -rf /mnt/server/temp

# Pindah direktori kerja
cd /mnt/server || exit

# Setup Wine environment
echo "[INSTALL] Menyiapkan WINEPREFIX dan konfigurasi awal..."
xvfb-run --auto-servernum wineboot

# Optional: install komponen Windows Common Controls jika dibutuhkan
# echo "[INSTALL] Menginstall winetricks comctl32..."
# xvfb-run --auto-servernum winetricks -q comctl32

# Download config default jika tidak ada
if [ ! -f config.json ]; then
  echo "[INSTALL] Mengunduh config.json default..."
  curl -sSL https://raw.githubusercontent.com/aruliazmi/open-mp/master/config.json -o config.json
else
  echo "[INSTALL] Menggunakan config.json yang sudah ada."
fi

# Ganti kepemilikan ke www-data
chown -R www-data:www-data /mnt

# Set environment HOME
export HOME=/mnt/server

echo "-----------------------------------------"
echo "✅ OpenMP Installation Completed"
echo "Eggs Created By Aruli Azmi"
echo "-----------------------------------------"
