variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "workers" {
  description = "Map of worker scripts to deploy"
  type = map(object({
    name        = string
    content     = string
    description = optional(string, "")
    
    plain_text_bindings   = optional(map(string), {})
    secret_text_bindings  = optional(map(string), {})
    kv_namespace_bindings = optional(map(string), {})
  }))
  default = {}
}

variable "worker_routes" {
  description = "Map of worker routes to create"
  type = map(object({
    zone_id     = string
    pattern     = string
    script_name = string
  }))
  default = {}
}
