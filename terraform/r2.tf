locals {
  cloudflare_account_id = "361201798b493df5f2731afcfbe1e188"
}

# Off-site backups: CNPG WAL + base backups and restic file backups.
# Near the VPS (Germany) for fast backup and restore; a different provider
# from the VPS, so one company's outage cannot take both.
resource "cloudflare_r2_bucket" "backups" {
  account_id    = local.cloudflare_account_id
  name          = "homelab-backups"
  location      = "weur"
  storage_class = "Standard"
}
