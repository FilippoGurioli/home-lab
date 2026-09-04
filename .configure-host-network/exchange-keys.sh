#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env"
if [ -f "$ENV_FILE" ]; then
  set -o allexport
  source "$ENV_FILE"
  set +o allexport
fi

sshpass -p "$PVE_PSW" ssh-copy-id -i ~/.ssh/homelab-proxmox.pub root@homelab.lan
sshpass -p "$GTW_PSW" ssh-copy-id -i ~/.ssh/homelab-gateway.pub root@gateway.homelab.lan
sshpass -p "$BKU_PSW" ssh-copy-id -i ~/.ssh/homelab-backup.pub rioly@backup.homelab.lan
sshpass -p "$APP_PSW" ssh-copy-id -i ~/.ssh/homelab-application.pub rioly@application.homelab.lan
