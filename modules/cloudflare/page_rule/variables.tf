variable "zone_id" {
  description = "The zone ID to add page rules to"
  type        = string
}

variable "page_rules" {
  description = "List of page rules to create"
  type = list(object({
    target   = string
    priority = optional(number, 1)
    actions  = map(any)
  }))
  default = []
}
