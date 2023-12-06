variable "vnet_name" {
  type    = string
  default = "vnet1"
}

variable "address_space" {
  type    = list(any)
  default = ["10.10.0.0/16"]
}

variable "resource_group_name" {
  type = string
}
variable "tags" {
  type    = map(any)
  default = {}
}

variable "location" {
  type = string
}

variable "nsg_name" {
  type    = string
  default = "nsg1"
}

variable "subnets" {
  type = map(any)
  default = {
    FrontEnd = {
      name             = "FrontEnd-Subnet"
      address_prefixes = ["10.10.1.0/24"]
    },
    BackEnd = {
      name             = "BackEnd-Subnet"
      address_prefixes = ["10.10.2.0/24"]
    }
  }
}