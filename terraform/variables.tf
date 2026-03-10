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

variable "vm_ip" {
  type = string 
}

variable "vm_user" {
  type = string
}

variable "vm_name" {
  type = string
}