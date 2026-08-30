# AGENTS.md

## Entry Points
- **Main orchestration**: `bootstrap.sh` – installs Ansible collections, sets up the gateway LXC, runs the Ansible playbook, and verifies connectivity.
- **Gateway configuration**: `./gateway/ansible/playbook.yml` – configures the Alpine gateway LXC (iptables, storage, networking).

## Critical Commands
- **Full setup**: `./bootstrap.sh` – installs dependencies, configures gateway, runs playbook, and confirms connectivity.
- **Gateway config only**: `ansible-playbook -i hosts.ini ./gateway/ansible/playbook.yml` – apply gateway configuration.
- **Verify connectivity**: `ansible gateway -i hosts.ini -m ping` – confirm the gateway is reachable.

## Architecture & Conventions
- **Gateway**: Alpine LXC container (WAN via vmbr0, internal LAN via vmbr1).
- **Services**: NextCloud, Immich, Jellyfin, Vaultwarden, Forgejo, Arstack, Audiobookshelf, etc. – managed externally; the gateway only exposes them.
- **Provisioning**: All infrastructure (VMs, networks, Ansible playbooks) is managed via Ansible; no manual Docker compose setup in this repo.
- **Dependencies**: Python 3 + Alpine packages (iptables, iproute2) installed by the bootstrap script.

## Setup Requirements
1. Gateways LXC must have `python3` and `apk` (Alpine) available.
2. Ansible collections (`community.general`) must be installed.
3. `hosts.ini` defines the gateway inventory.
4. `requirements.yml` lists Python dependencies (currently minimal).

## Operational Gotchas
- The gateway is the only node facing the external world; internal services are accessed via the gateway's exposed ports.
- Backup strategy uses Restic with 3-2-1 rule; daily/weekly/monthly retention policies.
- Proxmox host must have two virtual network bridges (`vmbr0` WAN, `vmbr1` internal LAN) configured beforehand.
- SSH access to the gateway requires root SSH enabled and authorized keys placed in `/root/.ssh/authorized_keys`.

## Testing
- Run `./bootstrap.sh` to validate the entire pipeline.
- Run `ansible-playbook -i hosts.ini ./gateway/ansible/playbook.yml` to test gateway configuration independently.
- Verify connectivity with `ansible gateway -i hosts.ini -m ping`.

## Important Constraints
- All services must be free software (gratis constraint).
- Vaultwarden must use its own Docker network with restricted egress.
- Backup data must be encrypted (Restic) and stored offsite.
