variable "pm_api_url" {
  type = string
}

variable "pm_api_token_id" {
  type = string
}

variable "pm_api_token_secret" {
  type      = string
  sensitive = true
}

variable "vm" {
  type = map(object({
    vm_id   = number
    vm_ip   = string
    vm_user = string
    vm_name = string
  }))
}