# The VPS was ordered by hand on 2026-11-12 and adopted into Terraform here.
# Once the import is applied, this block can stay: it is a no-op afterwards.
import {
  to = contabo_instance.node
  id = "203749255" # vmi3749255, 62.171.175.67
}

resource "contabo_instance" "node" {
  # Changing user_data REINSTALLS (wipes) the server and runs this cloud-init.
  user_data = templatefile("${path.module}/../cloud-init/node.yaml", {
    ops_password_hash  = var.ops_password_hash
    tailscale_auth_key = var.tailscale_auth_key
  })

  lifecycle {
    # Deleting this resource would cancel the server. Never allow it.
    prevent_destroy = true

    # Any of these REINSTALLS the server. user_data is ignored except during a
    # deliberate rebuild: see runbooks/rebuild-node.md.
    ignore_changes = [user_data, image_id, ssh_keys, root_password, default_user]
  }
}
