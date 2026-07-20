#!/usr/bin/env bash
set -e

INVENTORY="hosts.ini"

echo "==> [1/2] Bootstrapping Python on Alpine Gateway via Ansible Raw..."
ansible gateway -i "$INVENTORY" -m raw -a "apk add --no-cache python3 && [ -e /usr/bin/python ] || ln -s /usr/bin/python3 /usr/bin/python"

echo "==> [2/2] Running Ansible Ping Test..."
ansible gateway -i "$INVENTORY" -m ping

echo "==> All set! Python is installed and Ansible is fully connected."
