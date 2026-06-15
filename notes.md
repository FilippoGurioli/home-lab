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

## Details

### Gateway

- Responsible of exposing internal services with outer world
- In the first phase this should be done only through TaleScale in order to be secure
- In a second moment, it should feature firewall, reverse proxy and use the DuckDNS domain

### Authelia

- In case of failure apps should consent access only to LAN accesses

### Vaultwarden

- It should live inside its own VM
- As soon as my account is created, no other should
- Use its own 2FA instead of Authelia to avoid circular dependencies
- During backup procedures it should backup its data too
