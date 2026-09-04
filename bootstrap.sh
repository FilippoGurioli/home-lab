#!/usr/bin/env bash
set -e

[ -f .env ] || {
  echo "ERROR: .env file not found"
  exit 1
}

INVENTORY="hosts.ini"
REQUIREMENTS="requirements.yml"
GATEWAY_PLAYBOOK="./gateway/ansible/playbook.yml"
APPLICATION_PLAYBOOK="./application/ansible/playbook.yml"

echo "==> [1/5] Installing required Ansible collections..."
ansible-galaxy collection install -r "$REQUIREMENTS"

echo "==> [2/5] Bootstrapping Python on Alpine Gateway..."
ansible gateway -i "$INVENTORY" -m raw -a "apk add --no-cache python3 && [ -e /usr/bin/python ] || ln -s /usr/bin/python3 /usr/bin/python"

echo "==> [3/5] Verifying Connectivity (Ping)..."
ansible gateway -i "$INVENTORY" -m ping

echo "==> [4/5] Running Gateway Configuration Playbook..."
ansible-playbook -i "$INVENTORY" "$GATEWAY_PLAYBOOK"

echo "==> [5/5] Initializing Tailscale Login & Subnet Router..."
ssh root@gateway.homelab.lan "tailscale up --advertise-routes=10.0.0.0/24"

echo ""
echo "==> Gateway setup completed successfully!"
echo "==> ACTION REQUIRED: On the loaded tailscale dashboard click on the three dots of the gateway machine"
echo "==> go to \"Edit subnet routes...\" and tick the 10.0.0.0/24 route"

echo ""
echo "==> [1/4] Setting rioly as passwordless sudoer"
source .env
ssh rioly@application.homelab.lan "echo '$APP_PSW' | sudo -S sh -c 'echo \"rioly ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/rioly-ansible && chmod 0440 /etc/sudoers.d/rioly-ansible'"

echo "==> [2/4] Bootstrapping Python on Ubuntu-Server Application..."
ssh rioly@application.homelab.lan "sudo apt-get update && sudo apt-get install -y python3 python3-apt && [ -e /usr/bin/python ] || sudo ln -s /usr/bin/python3 /usr/bin/python"

echo "==> [3/4] Verifying Connectivity (Ping)..."
ansible application -i "$INVENTORY" -m ping

echo "==> [4/4] Running Application Configuration Playbook..."
ansible-playbook -i "$INVENTORY" "$APPLICATION_PLAYBOOK"

echo "Application setup completed successfully!"
