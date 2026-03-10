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
        address = "${var.vm_ip}/24"
        gateway = "192.168.1.254"
      }
    }

    user_account {
      keys = [file("~/.ssh/id_rsa.pub")]
    }
  }
}

resource "ansible_host" "db" {
  name   = var.vm_name
  groups = ["db_servers"]

  variables = {
    ansible_host                 = var.vm_ip
    ansible_user                 = var.vm_user
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
  }

  depends_on = [proxmox_virtual_environment_vm.nodes]
}
