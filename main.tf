resource "proxmox_virtual_environment_vm" "gateway_vm" {
  # 1. Use the node variable to tell Proxmox WHICH physical machine hosts this VM
  node_name = var.proxmox_node

  name        = "gateway"
  description = "Managed by Terraform - Network Gateway & Connectivity"
  tags        = ["infrastructure", "network"]

  cpu {
    cores = 1
    type  = "x86-64-v2-AES" # Good baseline for networking crypto/VPNs
  }

  memory {
    dedicated = 1024 # 1GB is plenty for a lightweight gateway
  }

  # 2. Use the network_bridge variable to attach the virtual network card
  network_device {
    bridge = var.network_bridge
  }

  # 3. Use the storage_pool variable to tell Proxmox where to allocate the OS disk
  disk {
    datastore_id = var.storage_pool
    file_id      = "local:iso/alpine-virt-3.19.1-x86_64.iso" #TODO: Placeholder for your chosen OS image
    interface    = "scsi0"
    size         = 10 # 10GB disk is more than enough for a gateway
  }

  boot_order = ["scsi0"] # tells where to search the boot
}
