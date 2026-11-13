# The VPS was ordered by hand on 2026-11-12 and adopted into Terraform here.
# Once the import is applied, this block can stay: it is a no-op afterwards.
import {
  to = contabo_instance.node
  id = "203749255" # vmi3749255, 62.171.175.67
}

resource "contabo_instance" "node" {
  lifecycle {
    # Deleting this resource would cancel the server. Never allow it.
    prevent_destroy = true

    # Changing any of these REINSTALLS (wipes) the server. Ignored until the
    # deliberate rebuild test, when user_data gets the cloud-init file.
    ignore_changes = [user_data, image_id, ssh_keys, root_password, default_user]
  }
}
