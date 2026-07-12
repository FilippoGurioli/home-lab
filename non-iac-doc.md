# Non Infrastructure-as-Code (Manual Configurations)

This documentation tracks manual host-level and infrastructure configurations that cannot be automated via IaC or inside the virtual machines. It ensures the environment can be replicated identically from the Proxmox WebUI/Shell.

## 1. Proxmox Host Initialization
- **No-Subscription Repositories:** Go to `homelab` (node) > `Updates` > `Repositories`. Disable the `pve-enterprise` repository and add the `no-subscription` community repository.
- **Subscription Nag Popup Removal:** 
    - `/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js`
    - remove the part where it sends the message "No valid subscription" (search for it, it is present just once)
    - save and run `systemctl restart pveproxy.service`, logout, refresh the browser page and login
- **Cluster Quorum (Only if running a 2-node setup):** To prevent split-brain blocks, connect an external **Corosync QDevice (QNetd)** on a separate lightweight device (e.g., Pi, old thin client) to act as the 3rd tie-breaker vote.

## 2. Proxmox Virtual Network Configuration (Pre-requisite for Gateway)
Before creating any VM or LXC, the host must have two distinct virtual network bridges configured under `Node` > `Network`:
1. `vmbr0` (External/WAN): Bridged to the physical network interface (connected to the home network/router).
2. `vmbr1` (Internal/LAN): A private, isolated virtual bridge **with no physical network interface attached**. This acts as our internal virtual switch.

## 3. Provisioning VM/LXC
- **ISO Storage:** Upload standard ISOs to `local` storage (`debian-stable`, `ubuntu-server`, `alpine-virt`).
- **Gateway LXC Creation:** Create via the Proxmox UI. It **must** have two network interfaces assigned:
    - `eth0` mapped to `vmbr0` (gets IP via DHCP from the home router).
    - `eth1` mapped to `vmbr1` (will be configured with a static IP via Ansible).
- **Target VMs Creation:** Create Application and Backup VMs. Map their network interfaces **only** to `vmbr1` (isolated LAN). They will remain offline until the Gateway is configured.

## 4. Post-Boot Manual Actions (Pre-Ansible Bootstrap)
- **Gateway Bootstrap:** Boot the Gateway LXC, ensure `sshd` is installed/enabled, and manually append the personal SSH public key into `/root/.ssh/authorized_keys` to hand over control to Ansible.

---

## Appendix: Hardware-Specific Reminders (Optional)
### If still using the GL.iNet Wi-Fi Bridge:
- Fix the GL.iNet to a **Static IP** on the main home router to avoid DHCP lease drops.
- Blind/lock the 2.4GHz Wi-Fi channel on the home router (e.g., channel 6 or 11) to avoid micro-disconnessions.
- Enable "Ping Watchdog" on the GL.iNet targeting the home router IP to auto-reboot the radio if it hangs.