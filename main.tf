resource "proxmox_virtual_environment_vm" "gateway_vm" {
  # 1. Use the node variable to tell Proxmox WHICH physical machine hosts this VM
  node_name = var.proxmox_node

  name        = "gateway"
  description = "Network Gateway & Connectivity"
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

resource "proxmox_virtual_environment_vm" "apps_vm" {
  node_name   = var.proxmox_node
  name        = "apps"
  description = "Home Lab Services"
  tags        = ["infrastructure", "apps"]

  cpu {
    cores = 4      # Give it more cores to handle Immich ML & Jellyfin transcoding
    type  = "host" # "host" passes your exact laptop CPU features straight to the VM (great for performance)
  }

  memory {
    dedicated = 4096 # 4GB of RAM as a starting baseline for your Docker stack
  }

  network_device {
    bridge = var.network_bridge
  }

  disk {
    datastore_id = var.storage_pool
    file_id      = "local:iso/ubuntu-24.04-server-cloudimg-amd64.img" #TODO: Placeholder for your Ubuntu image
    interface    = "scsi0"
    size         = 50 # 50GB disk to give your Docker volumes and system files room to breathe
  }

  boot_order = ["scsi0"]
}

resource "proxmox_virtual_environment_vm" "backups_vm" {
  node_name   = var.proxmox_node
  name        = "backups"
  description = "Data Backups & Terraform Backend"
  tags        = ["infrastructure", "security"]

  cpu {
    cores = 1 # Backups aren't CPU-heavy; 1 core keeps your laptop running cool
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 1024 # 1GB RAM is perfect for a lightweight Debian system running storage services
  }

  network_device {
    bridge = var.network_bridge
  }

  disk {
    datastore_id = var.storage_pool
    file_id      = "local:iso/debian-12-generic-amd64.img" #TODO: Placeholder for your Debian image
    interface    = "scsi0"
    size         = 100 # 100GB (or more) because this VM's primary job is to swallow incoming backup data
  }

  boot_order = ["scsi0"]
}
