#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
SOURCE_CONFIG="$SCRIPT_DIR/config"

echo "==> [1/4] Creating ~/.ssh directory..."
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

echo "==> [2/4] Generating SSH keys..."
bash "$SCRIPT_DIR/create-keys.sh"

echo "==> [3/4] Idempotent update of ~/.ssh/config..."
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

if grep -q "Host gateway.homelab.lan" "$SSH_CONFIG"; then
  echo "    - homelab configuration is already present, skipping the configuration of ~/.ssh/config."
else
  echo "    - Successfully added configuration in ~/.ssh/config..."
  echo "" >>"$SSH_CONFIG"
  cat "$SOURCE_CONFIG" >>"$SSH_CONFIG"
fi

echo "==> [4/4] Exchanging keys with remote hosts..."
bash "$SCRIPT_DIR/exchange-keys.sh"

echo "==> Setup completed successfully!"
