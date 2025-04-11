# Database Cluster Variables
variable "name" {
  description = "The name of the database cluster"
  type        = string
}

variable "engine" {
  description = "Database engine (mysql, pg, redis, mongodb)"
  type        = string
  
  validation {
    condition     = contains(["mysql", "pg", "redis", "mongodb"], var.engine)
    error_message = "Engine must be one of: mysql, pg, redis, mongodb."
  }
}

variable "engine_version" {
  description = "Engine version"
  type        = string
}

variable "size" {
  description = "Database size slug"
  type        = string
  default     = "db-s-1vcpu-1gb"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "sfo2"
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 1
  
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 3
    error_message = "Node count must be between 1 and 3."
  }
}

variable "private_network_uuid" {
  description = "The UUID of the VPC"
  type        = string
}

variable "tags" {
  description = "List of tags to apply to the cluster"
  type        = list(string)
  default     = []
}

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    day  = string
    hour = string
  })
  default = null
  
  validation {
    condition = var.maintenance_window == null ? true : (
      contains(["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"], lower(var.maintenance_window.day)) &&
      can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.maintenance_window.hour))
    )
    error_message = "Day must be a valid day of the week and hour must be in the format HH:MM."
  }
}

variable "prevent_destroy" {
  description = "Prevent destruction of the database cluster"
  type        = bool
  default     = false
}

# Database Variables
variable "databases" {
  description = "Set of database names to create"
  type        = set(string)
  default     = []
}

# User Variables
variable "users" {
  description = "Set of user names to create"
  type        = set(string)
  default     = []
}

# Connection Pool Variables
variable "connection_pools" {
  description = "Map of connection pools to create"
  type = map(object({
    mode    = string
    size    = number
    db_name = string
    user    = string
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for k, v in var.connection_pools : contains(["transaction", "session", "statement"], v.mode)
    ])
    error_message = "Connection pool mode must be one of: transaction, session, statement."
  }
}

# Firewall Variables
variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    type  = string
    value = string
  }))
  default = []
  
  validation {
    condition = alltrue([
      for rule in var.firewall_rules : contains(["ip_addr", "droplet", "tag", "app", "k8s"], rule.type)
    ])
    error_message = "Firewall rule type must be one of: ip_addr, droplet, tag, app, k8s."
  }
}
