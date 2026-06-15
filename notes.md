# Notes

Here I will insert my notes reguarding this project.

## Objective

Un-googling myself as much as possible.

## Services

- nextcloud
  - Caldav
- immich (with the correct extension in nextcloud to see in both places)
- jellyfin
- *arr stack
- audiobookshelf
- forgejo
- homepage
- Valutwarden
- gotify
- searXNG
- Authelia
- Uptime Kuma

## Machines

- Applications: holds all services listed above
- Gateway: the only one that faces the outer world, it communicates with internal machines
- Backup: holds a backup copy of the data (in a different HDD) and performs encryption + push of those data to a cloud provider ("cascading backups") - 3-2-1 rule

## Constraints

### Hardware Lifecycle

- Now: old laptop - i3-12th | 16GB
- Tomorrow:
  - or:
    - a NAS
    - a refurbished mini PC
  - and (when I change them with new ones):
    - my current laptop - r7-5700U | 16GB
    - my current desktop - r5-2600X | 16GB | sapphire GPU

### Others

- the software should be completely gratis (soft requirement)
- Immich should only use local ML

## Technologies

- OS: Proxmox
  - VMs:
    - Applications: Ubuntu Server LTS
    - Gateway: Alpine
    - Backup: Debian Stable
      - Restic (to encrypt and push data)

- Infrastructure:
  - Proxmox OS setup: done manually
  - VMs creation: done manually
  - VMs configuration: `Ansible`
    - sharable `.env` (via Ansible Vault)
    - particularly useful for Gateway node
- Services: single `Docker Compose` per VM
- External connectivity: p1-\[TaleScale\] -> p2-\[DuckDNS + SSL\]
- Internal connectivity (between VMs): Bare LAN connection

## Details

### Gateway

- Responsible of exposing internal services with outer world
- In the first phase this should be done only through TaleScale in order to be secure
- In a second moment, it should feature firewall, reverse proxy and use the DuckDNS domain

### Authelia

- In case of failure apps should consent access only to LAN accesses

### Vaultwarden

- Should have its own docker network
- No internet egress except for sync with Bitwarden clients
- reverse proxy is the only ingress point
- As soon as my account is created, no other should
- Use its own 2FA instead of Authelia to avoid circular dependencies
- During backup procedures it should backup its data too

### Restic

- Print the encryption key to paper, store it somewhere in my house and leave a copy to a close friend

### Backup scope

What to backup:

- nextcloud (DB too)
- immich
- vaultwarden
- forgejo

How:

- Where possible use built-in export tools
- Where not: stop applications -> copy DB and FS to staging -> restic backs up staging area -> restart applications

How often:

- daily to the out-site backup
- every hour to the staging site, only for Vaultwarden, only latest kept

Retention policy:

- the last 7 daily snapshots
- the last 4 weekly snapshots
- the last 12 monthly snapshots

NOTE: something deleted more than 12 month ago cannot be restored

### About connectivity

- Configure a fixed IP in the router DHCP for each VM
  - note that DHCP matches an IP with a MAC
  - Proxmox leaves the same MAC even if the VM changes the underlying metal
  - edge case: if the VM is re-created instead of being moved
- Inside each VM `.env` save the IPs of all other VMs
- Use `Traefik` as reverse proxy

### About Database

- Use a shared instance of `PostgreSQL`

### Operations order

1. Proxmox OS installation
2. Proxmox OS configuration
3. VM creation
4. Networking creation across VMs
5. Ansible playbook creation
6. Services creation
    1. PostgreSQL
    2. Authelia
    3. everything else

### Repo Structure

```shell
/
├── gateway/
│   ├── ansible/
│   └── docker/
├── applications/
│   ├── ansible/
│   └── docker/
├── common/       # ← Common logics
│   └── ansible/
├── backup/
│   ├── ansible/
│   └── docker/
└── secrets/      # ← Ansible Vault encrypted files
```
