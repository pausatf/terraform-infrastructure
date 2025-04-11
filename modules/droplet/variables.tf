variable "name" {
  description = "The name of the droplet"
  type        = string
}

variable "size" {
  description = "The size of the droplet"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "image" {
  description = "The image ID or slug of the droplet"
  type        = string
}

variable "region" {
  description = "The region of the droplet"
  type        = string
  default     = "sfo2"
}

variable "vpc_uuid" {
  description = "The UUID of the VPC"
  type        = string
}

variable "backups" {
  description = "Enable backups for the droplet"
  type        = bool
  default     = false
}

variable "monitoring" {
  description = "Enable monitoring for the droplet"
  type        = bool
  default     = false
}

variable "ssh_keys" {
  description = "List of SSH key IDs or fingerprints"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "List of tags to apply to the droplet"
  type        = list(string)
  default     = []
}

variable "prevent_destroy" {
  description = "Prevent destruction of the droplet"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data to be executed on droplet creation"
  type        = string
  default     = null
}
