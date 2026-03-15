resource "proxmox_virtual_environment_file" "cloud_init" {
  for_each = var.vm

  content_type = "snippets"
  datastore_id = "local"
  node_name    = "homelab"

  source_raw {
    file_name = "cloud-init-${each.key}.yml"
    data      = <<-EOF
      #cloud-config
      users:
        - name: ${each.value.vm_user}
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
  for_each = var.vm

  agent {
    enabled = true
    timeout = "2m"
  }

  name      = each.value.vm_name
  vm_id     = each.value.vm_id
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
        address = "${each.value.vm_ip}/24"
        gateway = "192.168.1.254"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init[each.key].id
  }
}

resource "ansible_host" "db" {
  for_each = var.vm

  name   = each.key
  groups = ["db_servers"]

  variables = {
    ansible_host                 = each.value.vm_ip
    ansible_user                 = each.value.vm_user
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
  }

  depends_on = [proxmox_virtual_environment_vm.nodes]
}
