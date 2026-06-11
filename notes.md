# Notes

Here I will insert my notes reguarding this project.

---

## Summary
- proxmox as OS
- old laptop as hw
- 3 VMs
  - gateway (handles connectivity) | Alpine Linux -> fast snapshots
  - apps (handles services with docker) | Ubuntu Server LTS
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
  - backups (handles backups of data from services and also terraform backend) | Debian Stable
- terraform for IaC
- different environments
  - production: my old laptop
  - development: still my old laptop, lol, I cannot use killercoda
