resource "proxmox_virtual_environment_vm" "nodes" {
  agent {
    enabled = true
    timeout = "2m"
  }

  name      = "db"
  vm_id     = 130
  node_name = "homelab"

  cpu {
    cores = 3
  }

  memory {
    dedicated = 4096
  }

  clone {
    vm_id = 9000
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 25
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id = "local"

    ip_config {
      ipv4 {
        address = "192.168.1.130/24"
        gateway = "192.168.1.254"
      }
    }

    user_account {
      keys = [file("~/.ssh/id_rsa.pub")]
    }
  }
}
