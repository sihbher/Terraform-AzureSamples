
variable "rg_name" {
  type    = string
  default = "WSPLUS-IaaS-Terraform-RG"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "deploybastion"{
    type    = bool
    default = false
}

variable "storage_account_basename" {
  type    = string
  default = "wsplussa"
}