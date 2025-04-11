# VPC Variables
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

# Domain Variables
variable "create_domain" {
  description = "Whether to create a domain"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "The name of the domain"
  type        = string
  default     = ""
}

variable "a_records" {
  description = "Map of A records to create"
  type = map(object({
    value = string
    ttl   = optional(number, 3600)
  }))
  default = {}
}

variable "cname_records" {
  description = "Map of CNAME records to create"
  type = map(object({
    value = string
    ttl   = optional(number, 3600)
  }))
  default = {}
}

variable "mx_records" {
  description = "Map of MX records to create"
  type = map(object({
    value    = string
    priority = optional(number, 10)
    ttl      = optional(number, 3600)
  }))
  default = {}
}

# Firewall Variables
variable "create_firewall" {
  description = "Whether to create a firewall"
  type        = bool
  default     = false
}

variable "firewall_name" {
  description = "The name of the firewall"
  type        = string
  default     = ""
}

variable "droplet_ids" {
  description = "List of droplet IDs to apply the firewall to"
  type        = list(string)
  default     = []
}

variable "inbound_rules" {
  description = "List of inbound rules"
  type = list(object({
    protocol         = string
    port_range       = optional(string)
    source_addresses = optional(list(string), ["0.0.0.0/0", "::/0"])
    source_tags      = optional(list(string))
  }))
  default = []
}

variable "outbound_rules" {
  description = "List of outbound rules"
  type = list(object({
    protocol              = string
    port_range            = optional(string)
    destination_addresses = optional(list(string), ["0.0.0.0/0", "::/0"])
    destination_tags      = optional(list(string))
  }))
  default = []
}
