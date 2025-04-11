# Cloudflare Configuration for PAUSATF

resource "cloudflare_zone" "pausatf_com" {
  zone       = "pausatf.com"
  account_id = var.cloudflare_account_id
}

resource "cloudflare_zone_settings_override" "pausatf_com_settings" {
  zone_id = cloudflare_zone.pausatf_com.id

  settings {
    ssl         = "strict"     # SSL/TLS Settings
    cache_level = "aggressive" # Cache Settings
  }
}

# DNS Records
resource "cloudflare_record" "pausatf_com_root_a" {
  zone_id = cloudflare_zone.pausatf_com.id
  name    = "@"
  value   = module.wordpress_droplet.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "pausatf_com_www_a" {
  zone_id = cloudflare_zone.pausatf_com.id
  name    = "www"
  value   = module.wordpress_droplet.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "dev_a" {
  zone_id = cloudflare_zone.pausatf_com.id
  name    = "dev"
  value   = module.wordpress_droplet.ipv4_address
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "stage_a" {
  zone_id = cloudflare_zone.pausatf_com.id
  name    = "stage"
  value   = module.wordpress_droplet.ipv4_address
  type    = "A"
  proxied = true
}

# Page Rules
resource "cloudflare_page_rule" "wordpress_admin_cache_bypass" {
  zone_id = cloudflare_zone.pausatf_com.id
  target  = "https://pausatf.com/wp-admin/*"

  actions {
    cache_level = "bypass"
  }

  priority = 1
}

resource "cloudflare_page_rule" "wordpress_login_cache_bypass" {
  zone_id = cloudflare_zone.pausatf_com.id
  target  = "https://pausatf.com/wp-login.php*"

  actions {
    cache_level = "bypass"
  }

  priority = 2
}

resource "cloudflare_page_rule" "static_content_cache_everything" {
  zone_id = cloudflare_zone.pausatf_com.id
  target  = "https://pausatf.com/wp-content/*"

  actions {
    cache_level = "cache_everything"
  }

  priority = 3
}
