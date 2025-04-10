variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "zone_name" {
  description = "The domain name to create a zone for"
  type        = string
}

variable "settings" {
  description = "Zone settings"
  type = object({
    plan = optional(string, "free")
    type = optional(string, "full")
  })
  default = {
    plan = "free"
    type = "full"
  }
}

variable "zone_settings" {
  description = "Zone settings override"
  type        = map(any)
  default     = {}
}
