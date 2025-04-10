terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Create worker scripts
resource "cloudflare_worker_script" "this" {
  for_each = var.workers

  name       = each.value.name
  content    = each.value.content
  account_id = var.account_id

  dynamic "plain_text_binding" {
    for_each = lookup(each.value, "plain_text_bindings", {})
    content {
      name = plain_text_binding.key
      text = plain_text_binding.value
    }
  }

  dynamic "secret_text_binding" {
    for_each = lookup(each.value, "secret_text_bindings", {})
    content {
      name = secret_text_binding.key
      text = secret_text_binding.value
    }
  }

  dynamic "kv_namespace_binding" {
    for_each = lookup(each.value, "kv_namespace_bindings", {})
    content {
      name         = kv_namespace_binding.key
      namespace_id = kv_namespace_binding.value
    }
  }
}

# Create worker routes
resource "cloudflare_worker_route" "this" {
  for_each = var.worker_routes

  zone_id     = each.value.zone_id
  pattern     = each.value.pattern
  script_name = each.value.script_name
}
