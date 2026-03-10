resource "proxmox_virtual_environment_file" "cloud_init" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "homelab"

  source_raw {
    file_name = "cloud-init-db.yml"
    data      = <<-EOF
      #cloud-config
      users:
        - name: ${var.vm_user}
          groups: sudo
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          lock_passwd: true
          ssh_authorized_keys:
            - ${trimspace(file("~/.ssh/id_rsa.pub"))}
    EOF
  }
}

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

    user_data_file_id = proxmox_virtual_environment_file.cloud_init.id
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
