variable "zone_name" {
  description = "The domain name of the existing zone"
  type        = string
}

variable "zone_settings" {
  description = "Zone settings override"
  type        = map(any)
  default     = {}
}
