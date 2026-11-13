# Only needed for a node rebuild (runbooks/rebuild-node.md). Defaults keep
# everyday plans working without them; user_data is ignored outside a rebuild.
variable "ops_password_hash" {
  description = "SHA-512 crypt hash of the ops password (openssl passwd -6)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "tailscale_auth_key" {
  description = "One-time, non-reusable Tailscale auth key tagged tag:server."
  type        = string
  default     = ""
  sensitive   = true
}
