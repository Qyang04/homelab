# Rebuild the node from scratch

Wipes the VPS and rebuilds it from `cloud-init/node.yaml`. Used for the
disaster-recovery drill and for recovering a broken node.

**Wipes all data on the server.** Restore app data from R2 backups afterwards.

## Before

1. Have the `ops` password hash: on the old node run `openssl passwd -6`
   (or on any Linux machine). Keep the hash in the password manager.
2. Tailscale admin → Settings → Keys → **Generate auth key**:
   reusable **off**, ephemeral **off**, pre-approved **on**, tags **tag:server**,
   expiry **1 day**.
3. In one PowerShell window, set the usual credentials (R2, Cloudflare,
   Contabo) and the two rebuild inputs:

   ```powershell
   $env:TF_VAR_ops_password_hash  = Read-Host "ops password hash"
   $env:TF_VAR_tailscale_auth_key = Read-Host "Tailscale auth key"
   ```

## Rebuild

1. In `terraform/instance.tf`, remove `user_data` from `ignore_changes`.
2. `terraform plan "-out=rebuild.tfplan"`. Expect exactly
   `0 to add, 1 to change, 0 to destroy` on `contabo_instance.node`,
   with `user_data` changing (shown as sensitive). Anything else: stop.
3. `terraform apply rebuild.tfplan`
4. Tailscale admin → Machines: **remove the old `vmi3749255`** so the new
   node can take the same name.
5. Wait about 5–10 minutes, then check from the PC:
   - `ssh duit` logs in as `ops`
   - `sudo ufw status` shows the rules; `sudo k3s kubectl get nodes` is `Ready`
   - `ssh root@62.171.175.67` times out
6. Keep the node's Tailscale IP stable: Tailscale admin → Machines →
   `vmi3749255` → Edit machine IPv4 → `100.82.116.83`. It is referenced in
   `terraform/dns.tf` (`tailscale_ip`) and `apps/traefik/helmchartconfig.yaml`
   (`externalIPs`); if it ever has to change, update both.
7. Put `user_data` back into `ignore_changes`, `terraform plan` shows
   no changes, delete `rebuild.tfplan`, commit.

`cloud-init status` reports `error` on every boot because of Contabo's own
injected `bootcmd` (`pkill -HUP sshd` exits 1). Expected; check that the
error list contains only `bootcmd` and that `runcmd` / `scripts_user` succeeded.

## If it goes wrong

Contabo panel → VNC console, log in as `ops`, read
`sudo cat /var/log/cloud-init-output.log`.
