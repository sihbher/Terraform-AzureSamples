
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_basename" {
  type    = string
  default = "wsplussa"
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_account_replication_type" {
  type    = string
  default = "LRS"
}

variable "tags" {
  type = map(any)
}