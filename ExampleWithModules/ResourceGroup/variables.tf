variable "resource_group_basename" {
  type    = string
  default = "WSPLUS-IaaS-Terraform"
}

variable "location" {
  type    = string
  default = "East US"
}

variable "tags" {
  type = map(any)
  default = {
    environment = "Test"
    delete      = "yes"
  }
}