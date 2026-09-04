#!/usr/bin/env bash

ssh-copy-id -i ~/.ssh/homelab-proxmox.pub root@homelab.lan
ssh-copy-id -i ~/.ssh/homelab-gateway.pub root@gateway.homelab.lan
ssh-copy-id -i ~/.ssh/homelab-backup.pub root@backup.homelab.lan
ssh-copy-id -i ~/.ssh/homelab-application.pub root@application.homelab.lan
