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
- Brevo (SMTP relay - up to 300 emails per day)

## Machines

- Applications: holds all services listed above
- Gateway: the only one that faces the outer world, it communicates with internal machines
- Backup: holds a backup copy of the data (in a different HDD) and performs encryption + push of those data to a cloud provider ("cascading backups") - 3-2-1 rule

## Constraints

### Hardware Lifecycle

- Now: old laptop - i3-12th | 8GB
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
    - Backup: Debian Stable
      - Restic (to encrypt and push data)
  - LXCs:
    - Gateway: Alpine

- Infrastructure:
  - Proxmox OS setup: done manually
  - VMs creation: done manually
  - VMs configuration: `Ansible`
    - sharable `.env` (via Ansible Vault)
    - particularly useful for Gateway node
- Services: single `Docker Compose` per VM
- External connectivity: p1-\[TailScale\] -> p2-\[DuckDNS + SSL\]
- Internal connectivity (between VMs): Bare LAN connection

- Backup:
  - Layer 1 (VM-level): Proxmox Backup Server (PBS) — automated, deduplicated, incremental VM snapshots
  - Layer 2 (app-level): Restic — granular, per-service backups (existing plan)

## Details

### Gateway

- Responsible of exposing internal services with outer world
- In the first phase this should be done only through TailScale in order to be secure
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

Two layers, covering different failure modes:

**Layer 1 — Proxmox Backup Server (catastrophic recovery)**
- Scope: full VM images (Applications, Gateway, Backup)
- Storage: PBS datastore on the Backup VM's separate HDD
- Dedup + incremental via dirty-bitmap tracking; client-side encrypted
- Retention: same 7 daily / 4 weekly / 12 monthly scheme, via PBS's keep-* options
- Restore: fully GUI-driven through Proxmox — no scripts or docs required
- Requires QEMU guest agent on the Applications VM for fsfreeze consistency (important for Postgres)

**Layer 2 — Restic (granular, per-service)**
What to backup:
- nextcloud (DB too)
- immich
- vaultwarden
- forgejo

How:
- Where possible use built-in export tools
- Where not: stop application → copy DB and FS to staging → restic backs up staging area → restart application

How often:
- daily to the out-site backup
- every hour to the staging site, only for Vaultwarden, only latest kept

Retention policy:
- last 7 daily snapshots
- last 4 weekly snapshots
- last 12 monthly snapshots

NOTE: something deleted more than 12 months ago cannot be restored via this layer (Layer 1 VM snapshots follow their own retention and are a separate recovery path).

**Requirement:** a `RESTORE.md` documenting the exact Restic restore commands, tested end-to-end at least once. Layer 1 doesn't need this — Proxmox's UI is the documentation.

**Interim/stopgap:** until Vaultwarden's Layer 2 backup is live, do a manual encrypted vault export periodically.

### About connectivity

- Assign to each VM a hostname inside the GL.iNet router so that they can communicate with each other without the need of using IP addresses
- Use `Traefik` as reverse proxy

### About Database

- Use `PostgreSQL`

### Operations order

1. Proxmox OS installation
2. Proxmox OS configuration
3. VM creation
4. Networking creation across VMs
5. Ansible playbook creation
6. Services creation
    1. Traefik
    2. Authelia
    3. Vaultwarden
    4. Everything else
7. Backup setup
    1. PBS datastore + VM backup jobs (Layer 1) — can be done opportunistically, doesn't depend on the full service set existing
    2. Restic granular pipeline (Layer 2) — build once the service set is settled, covering Nextcloud, Immich, Vaultwarden, Forgejo

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
