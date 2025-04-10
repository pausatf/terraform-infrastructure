variable "zone_id" {
  description = "The zone ID to add firewall rules to"
  type        = string
}

variable "rules" {
  description = "List of firewall rules to create"
  type = list(object({
    description = string
    expression  = string
    action      = string
    priority    = optional(number, 1)
  }))
  default = []
}
