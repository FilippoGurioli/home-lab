#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_ENV="$(realpath "$SCRIPT_DIR/../.env")"
APP_ENV="$(realpath "$SCRIPT_DIR/../application/docker/.env")"

askPassword() {
  local service="$1"
  local password

  printf "Insert password for %s: " "$service" >&2

  stty -echo
  read -r password
  stty echo

  printf "\n" >&2

  echo "$password"
}

askInput() {
  local prompt="$1"
  local output
  printf "%s" "$prompt" >&2
  read -r output
  printf "\n" >&2
  echo "$output"
}

getRandomSecret() {
  echo "$(openssl rand -hex 32)"
}

setRootEnvPasswords() {
  PVE_PSW="$(askPassword "Proxmox root Account")"
  GTW_PSW="$(askPassword "Gateway LCX root Account")"
  BKU_PSW="$(askPassword "Backup VM rioly Account")"
  APP_PSW="$(askPassword "Application VM rioly Account")"

  {
    echo "PVE_PSW=\"$PVE_PSW\""
    echo "GTW_PSW=\"$GTW_PSW\""
    echo "BKU_PSW=\"$BKU_PSW\""
    echo "APP_PSW=\"$APP_PSW\""
  } >"$ROOT_ENV"

  echo "[INFO] Passwords successfully written to $ROOT_ENV"
}

setAppEnvPasswords() {
  DUCKDNS_TOKEN="$(askInput "Insert the duck dns token (can be found at https://www.duckdns.org/ after login): ")"

  POSTGRES_ADMIN_PASSWORD="$(getRandomSecret)"
  AUTHELIA_POSTGRES_PASSWORD="$(getRandomSecret)"
  VAULTWARDEN_POSTGRES_PASSWORD="$(getRandomSecret)"
  IMMICH_POSTGRES_PASSWORD="$(getRandomSecret)"
  AUTHELIA_JWT_SECRET="$(getRandomSecret)"
  AUTHELIA_SESSION_SECRET="$(getRandomSecret)"
  AUTHELIA_STORAGE_KEY="$(getRandomSecret)"
  AUTHELIA_HMAC_SECRET="$(getRandomSecret)"

  AUTHELIA_ADMIN_PASSWORD="$(askPassword "Authelia admin Account")"
  AUTHELIA_ADMIN_PASSWORD_HASH=$(docker run --rm authelia/authelia:4 authelia crypto hash generate argon2 --password "$AUTHELIA_ADMIN_PASSWORD" | sed 's/^Digest: //')

  VAULTWARDEN_ADMIN_TOKEN_PLAIN="$(askPassword "Vaultwarden admin Token")"
  VAULTWARDEN_ADMIN_TOKEN=$(printf '%s' "$VAULTWARDEN_ADMIN_TOKEN_PLAIN" | docker run --rm -i alpine sh -c \
    'apk add -q argon2 && argon2 "$(head -c 32 /dev/urandom | base64)" -e -id -k 65540 -t 3 -p 4')

  AUTHELIA_IMMICH_CLIENT_SECRET="$(getRandomSecret)"
  AUTHELIA_IMMICH_CLIENT_SECRET_HASH="$(docker run --rm authelia/authelia:4 authelia crypto hash generate pbkdf2 --variant sha512 --password "$AUTHELIA_IMMICH_CLIENT_SECRET" | sed 's/^Digest: //')"
  {
    echo "DUCKDNS_TOKEN='$DUCKDNS_TOKEN'"
    echo "POSTGRES_ADMIN_PASSWORD='$POSTGRES_ADMIN_PASSWORD'"
    echo "VAULTWARDEN_POSTGRES_PASSWORD='$VAULTWARDEN_POSTGRES_PASSWORD'"
    echo "# vaultwarden admin plain token (if you found yourself to have forgot it): $VAULTWARDEN_ADMIN_TOKEN_PLAIN"
    echo "VAULTWARDEN_ADMIN_TOKEN='$VAULTWARDEN_ADMIN_TOKEN'"
    echo "IMMICH_POSTGRES_PASSWORD='$IMMICH_POSTGRES_PASSWORD'"
    echo "AUTHELIA_POSTGRES_PASSWORD='$AUTHELIA_POSTGRES_PASSWORD'"
    echo "# authelia admin plain password (if you found yourself to have forgot it): $AUTHELIA_ADMIN_PASSWORD"
    echo "AUTHELIA_ADMIN_PASSWORD_HASH='$AUTHELIA_ADMIN_PASSWORD_HASH'"
    echo "AUTHELIA_JWT_SECRET='$AUTHELIA_JWT_SECRET'"
    echo "AUTHELIA_SESSION_SECRET='$AUTHELIA_SESSION_SECRET'"
    echo "AUTHELIA_STORAGE_KEY='$AUTHELIA_STORAGE_KEY'"
    echo "AUTHELIA_HMAC_SECRET='$AUTHELIA_HMAC_SECRET'"
    echo "# authelia immich client secret (to be inserted later on in immich administrator > OAuth): $AUTHELIA_IMMICH_CLIENT_SECRET"
    echo "AUTHELIA_IMMICH_CLIENT_SECRET_HASH='$AUTHELIA_IMMICH_CLIENT_SECRET_HASH'"
  } >"$APP_ENV"

  echo "[INFO] Passwords successfully written to $APP_ENV"
}

[ -f "$ROOT_ENV" ] && {
  echo "[WARN] root .env found, do you want to override it? (y/N)"
  read override
  case "${override,,}" in
  y | yes)
    echo "[INFO] Overriding $ROOT_ENV..."
    rm -rf "$ROOT_ENV"
    touch "$ROOT_ENV"
    setRootEnvPasswords
    ;;
  *)
    echo "[INFO] Keeping existing $ROOT_ENV. Skipping override."
    ;;
  esac
}

[ -f "$APP_ENV" ] && {
  echo "[WARN] application .env found, do you want to override it? (y/N)"
  read override
  case "${override,,}" in
  y | yes)
    echo "[INFO] Overriding $APP_ENV..."
    rm -rf "$APP_ENV"
    touch "$APP_ENV"
    setAppEnvPasswords
    ;;
  *)
    echo "[INFO] Keeping existing $APP_ENV. Skipping override."
    ;;
  esac
}
