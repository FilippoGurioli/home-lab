# Non Infrastructure-as-Code (Manual Configurations)

This documentation tracks manual host-level and infrastructure configurations that cannot be automated via IaC or inside the virtual machines. It ensures the environment can be replicated identically from the Proxmox WebUI/Shell.

## 1. Proxmox Host Initialization
- **No-Subscription Repositories:** Go to `homelab` (node) > `Updates` > `Repositories`. Disable the `pve-enterprise` repository and add the `no-subscription` community repository.
- **Subscription Nag Popup Removal:** - `/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js`
    - remove the part where it sends the message "No valid subscription" (search for it, it is present just once)
    - save and run `systemctl restart pveproxy.service`, logout, refresh the browser page and login
- **Disable Laptop Lid Switch Suspend:** To prevent the laptop from going to sleep when the lid is closed:
    - Edit `/etc/systemd/logind.conf` and set:
      ```text
      HandleLidSwitch=ignore
      HandleLidSwitchDocked=ignore
      ```
    - Restart the service: `systemctl restart systemd-logind`
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
- **Gateway Bootstrap & SSH Setup:** Boot the Gateway LXC, ensure `sshd` is installed/enabled (`apk add openssh` and `rc-update add sshd`).
- **Enable Root SSH Access:**
    - Edit `/etc/ssh/sshd_config` and ensure `PermitRootLogin yes` (or `prohibit-password`) is active.
    - Append the personal SSH public key into `/root/.ssh/authorized_keys` to hand over control to Ansible.
    - Start/restart the SSH service (`service sshd restart`).

---

## Appendix: Quick Reference & Hardware Reminders

### Network Topology
| Device / Hostname | Subnet / Interface | IP Address | Gateway | Note |
| :--- | :--- | :--- | :--- | :--- |
| Proxmox Host | LAN (`vmbr0`) | `192.168.x.x` | Home Router | Node UI (Port 8006) |
| Gateway LXC (WAN) | `vmbr0` (`eth0`) | DHCP / Static | Home Router | External Access |
| Gateway LXC (LAN) | `vmbr1` (`eth1`) | `10.0.0.1/24` | - | Internal Gateway |
| Backup VM | `vmbr1` (`eth0`) | `10.0.0.2/24` | `10.0.0.1` | Internal Only |
| App VM | `vmbr1` (`eth0`) | `10.0.0.3/24` | `10.0.0.1` | Internal Only |

### If still using the GL.iNet Wi-Fi Bridge:
- Fix the GL.iNet to a **Static IP** on the main home router to avoid DHCP lease drops.
- Blind/lock the 2.4GHz Wi-Fi channel on the home router (e.g., channel 6 or 11) to avoid micro-disconnessions.
- Enable "Ping Watchdog" on the GL.iNet targeting the home router IP to auto-reboot the radio if it hangs.
