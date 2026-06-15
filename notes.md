# Notes

Here I will insert my notes reguarding this project.

## Objective

Un-googling myself as much as possible.

## Services

- nextcloud
- immich (with the correct extension in nextcloud to see in both places)
- jellyfin
- *arr stack
- audiobookshelf
- forgejo
- homepage
- the password manager
- gotify
- searXNG
- Caldav

## Machines

- Applciations: holds all services listed above
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
- the software should be completely gratis
- use tailscale for connectivity security
  - after tailscale is set up, plan (if needed) to use duckdns and SSL

## Techonologies

- OS: Proxmox
  - VMs:
    - Applications: Ubuntu Server LTS
    - Gateway: Alpine
    - Backup: Debian Stable
