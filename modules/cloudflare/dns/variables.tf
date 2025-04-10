variable "zone_id" {
  description = "The zone ID to add records to"
  type        = string
}

variable "records" {
  description = "List of DNS records to create"
  type = list(object({
    name    = string
    type    = string
    value   = string  # This is used as 'content' in the resource
    ttl     = optional(number, 1)
    proxied = optional(bool, true)
  }))
  default = []
}
