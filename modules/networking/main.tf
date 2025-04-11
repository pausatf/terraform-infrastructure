terraform {
  # Terraform version constraint
  required_version = ">= 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

data "digitalocean_vpc" "existing" {
  name = var.vpc_name
}

resource "digitalocean_domain" "this" {
  count = var.create_domain ? 1 : 0
  name  = var.domain_name
}

resource "digitalocean_record" "a" {
  for_each = var.create_domain ? var.a_records : {}

  domain = digitalocean_domain.this[0].name
  type   = "A"
  name   = each.key
  value  = each.value.value
  ttl    = lookup(each.value, "ttl", 3600)
}

resource "digitalocean_record" "cname" {
  for_each = var.create_domain ? var.cname_records : {}

  domain = digitalocean_domain.this[0].name
  type   = "CNAME"
  name   = each.key
  value  = each.value.value
  ttl    = lookup(each.value, "ttl", 3600)
}

resource "digitalocean_record" "mx" {
  for_each = var.create_domain ? var.mx_records : {}

  domain   = digitalocean_domain.this[0].name
  type     = "MX"
  name     = each.key
  value    = each.value.value
  priority = lookup(each.value, "priority", 10)
  ttl      = lookup(each.value, "ttl", 3600)
}

resource "digitalocean_firewall" "this" {
  count = var.create_firewall ? 1 : 0

  name        = var.firewall_name
  droplet_ids = var.droplet_ids

  dynamic "inbound_rule" {
    for_each = var.inbound_rules

    content {
      protocol         = inbound_rule.value.protocol
      port_range       = lookup(inbound_rule.value, "port_range", null)
      source_addresses = lookup(inbound_rule.value, "source_addresses", ["0.0.0.0/0", "::/0"])
      source_tags      = lookup(inbound_rule.value, "source_tags", null)
    }
  }

  dynamic "outbound_rule" {
    for_each = var.outbound_rules

    content {
      protocol              = outbound_rule.value.protocol
      port_range            = lookup(outbound_rule.value, "port_range", null)
      destination_addresses = lookup(outbound_rule.value, "destination_addresses", ["0.0.0.0/0", "::/0"])
      destination_tags      = lookup(outbound_rule.value, "destination_tags", null)
    }
  }
}
