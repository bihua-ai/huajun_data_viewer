#!/usr/bin/env bash

set -e

# Hold current directory in variable
current_directory="$(pwd)"

echo "[INFO] Stopping and removing current deployment..."

cd /opt/huajun/admin && sudo docker compose down || true
cd /opt/huajun/client && sudo docker compose down || true
cd /opt/huajun/device_hub/services && sudo ./service_stop.sh || true
cd /opt/huajun/timescaledb && sudo docker compose down || true

# Remove admin and client docker images
sudo docker rmi -f $(sudo docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' | grep -E '^(admin|client)' | awk '{print $2}') || true

# Remove huajun directory
sudo rm -rf /opt/huajun

echo "[INFO] Deploying new one..."

cd "$current_directory"
cp -r ./huajun /opt
cp -f ../admin_config.json /opt/huajun/admin
cp -f ../client_config.json /opt/huajun/client

cd /opt/huajun/timescaledb && sudo docker compose up -d
cd /opt/huajun/device_hub/services && sudo ./service_setup.sh

# Load and start admin docker image
echo "[INFO] Loading admin docker image..."
cd /opt/huajun/admin
admin_docker_image=$(ls admin*.tar | head -n 1)
sudo docker load -i "$admin_docker_image"
sudo docker compose up -d

# Load and start client docker image
echo "[INFO] Loading client docker image..."
cd /opt/huajun/client
client_docker_image=$(ls client*.tar | head -n 1)
sudo docker load -i "$client_docker_image"
sudo docker compose up -d

# --- Repeat process for redeployment ---
# cd /opt/huajun/timescaledb && docker compose up -d
# cd /opt/huajun/device_hub/services && ./service_setup.sh
# cd /opt/huajun/admin && docker compose up -d
# cd /opt/huajun/client && docker compose up -d

echo "[INFO] Done."
