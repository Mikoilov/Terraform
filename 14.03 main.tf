provider "proxmox" {
  endpoint = "https://192.168.111.180:8006/"
  username = "root@pam"
  password = "Par240XXX"
  insecure = true

  ssh {
    agent = true
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"

  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  count     = 3  # Create 3 VMs dynamically
  name      = "test-ubuntu-${count.index + 1}"  # VM names: test-ubuntu-1, test-ubuntu-2, test-ubuntu-3
  node_name = "pve"

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.111.${181 + count.index}/24"  # Dynamic IPs: 192.168.111.181, 192.168.111.182, 192.168.111.183
        gateway = "192.168.111.1"
      }
    }

    user_account {
      username = "root"
      password = "Par240XXX"
      keys     = [var.ssh_key]
    }
  }

  

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }
}
