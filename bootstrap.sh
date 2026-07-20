#!/usr/bin/env bash
set -e

INVENTORY="hosts.ini"
REQUIREMENTS="requirements.yml"
PLAYBOOK="./gateway/ansible/playbook.yml"

echo "==> [1/4] Installing required Ansible collections.."
ansible-galaxy collection install -r "$REQUIREMENTS"

echo "==> [2/4] Bootstrapping Python on Alpine Gateway..."
ansible gateway -i "$INVENTORY" -m raw -a "apk add --no-cache python3 && [ -e /usr/bin/python ] || ln -s /usr/bin/python3 /usr/bin/python"

echo "==> [3/4] Verifying Connectivity (Ping)..."
ansible gateway -i "$INVENTORY" -m ping

echo "==> [4/4] Running Gateway Configuration Playbook..."
ansible-playbook -i "$INVENTORY" "$PLAYBOOK"

echo "==> Gateway setup completed successfully!"
