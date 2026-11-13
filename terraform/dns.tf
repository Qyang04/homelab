locals {
  domain    = "luiqiuyang.com"
  public_ip = "62.171.175.67" # Contabo VPS, eth0

  # Public apps: name -> IPv4. Admin tools are added later with the Tailscale IP.
  public_records = {
    duit           = local.public_ip
    "duit-staging" = local.public_ip
  }
}

data "cloudflare_zone" "main" {
  filter = {
    name = local.domain
  }
}

resource "cloudflare_dns_record" "public" {
  for_each = local.public_records

  zone_id = data.cloudflare_zone.main.id
  name    = "${each.key}.${local.domain}"
  type    = "A"
  content = each.value
  ttl     = 300
  proxied = false
  comment = "managed by terraform (homelab)"
}
