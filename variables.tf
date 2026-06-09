variable "proxmox_api_url" {
  type        = string
  description = "The full API URL of my Proxmox server"
}

variable "proxmox_token_id" {
  type        = string
  description = "The token ID generated in Proxmox"
}

variable "proxmox_token_secret" {
  type        = string
  description = "The long secret key string for the token"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "The name of your physical Proxmox node"
  default     = "pve"
}

variable "storage_pool" {
  type        = string
  description = "The Proxmox storage pool where VM disks will live"
  default     = "local-lvm" # Default for standard Proxmox installs
}

variable "network_bridge" {
  type        = string
  description = "The network bridge to attach the VMs to"
  default     = "vmbr0"
}
