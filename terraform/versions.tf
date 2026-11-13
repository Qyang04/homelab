terraform {
  required_version = "~> 1.17.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.29"
    }
    contabo = {
      source  = "contabo/contabo"
      version = "0.1.44" # pre-1.0: pin exactly, minor releases may break
    }
  }
}

# Reads the API token from the CLOUDFLARE_API_TOKEN environment variable.
provider "cloudflare" {}

# Reads CNTB_OAUTH2_CLIENT_ID, CNTB_OAUTH2_CLIENT_SECRET, CNTB_OAUTH2_USER and
# CNTB_OAUTH2_PASS. These credentials control the whole Contabo account
# (including ordering servers), so they are used from the PC only, never in CI.
provider "contabo" {}
