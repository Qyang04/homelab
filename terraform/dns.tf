locals {
  domain    = "luiqiuyang.com"
  public_ip = "62.171.175.67" # Contabo VPS, eth0

  # Node's Tailscale IP. Changes when the node is rebuilt: update it then
  # (runbooks/rebuild-node.md).
  tailscale_ip = "100.82.116.83"

  # Public apps: name -> IPv4.
  public_records = {
    duit           = local.public_ip
    "duit-staging" = local.public_ip
  }

  # Admin tools: resolve to the Tailscale IP, so only tailnet devices can
  # connect. Traefik also enforces a tailnet-only IP allowlist for them.
  tailnet_records = {
    argocd = local.tailscale_ip
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

resource "cloudflare_dns_record" "tailnet" {
  for_each = local.tailnet_records

  zone_id = data.cloudflare_zone.main.id
  name    = "${each.key}.${local.domain}"
  type    = "A"
  content = each.value
  ttl     = 300
  proxied = false
  comment = "managed by terraform (homelab), tailnet only"
}
