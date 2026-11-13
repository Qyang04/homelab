# State lives in Cloudflare R2 (S3-compatible). The bucket was created by hand
# once (bootstrap); Terraform cannot create the bucket that holds its own state.
# Credentials come from AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (an R2 API
# token scoped to this bucket only).
terraform {
  backend "s3" {
    bucket       = "homelab-tfstate"
    key          = "homelab/terraform.tfstate"
    region       = "auto"
    use_lockfile = true

    endpoints = {
      s3 = "https://361201798b493df5f2731afcfbe1e188.r2.cloudflarestorage.com"
    }

    # R2 is not AWS: skip the AWS-only checks.
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}
