terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.1"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.3"
    }
  }
}

provider "proxmox" {
  endpoint = var.pm_api_url

  api_token = "${var.pm_api_token_id}=${var.pm_api_token_secret}"

  insecure = true
}
