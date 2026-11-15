# homelab

Single-node k3s platform on a Contabo VPS that hosts [Duit](https://github.com/Qyang04/duit) and future apps.

| Folder | What |
|---|---|
| `terraform/` | Cloudflare DNS, R2 backup bucket, Contabo VPS |
| `cloud-init/` | Node bootstrap: hardening, Tailscale, k3s |
| `clusters/prod/` | Argo CD app-of-apps: one Application per platform piece |
| `apps/` | Helm values and manifests those Applications deploy |
| `secrets/` | SOPS + age encrypted files (see `.sops.yaml` for who can decrypt what) |
| `runbooks/` | Rebuild and recovery procedures |
| `scripts/` | `load-secrets.ps1`: decrypt Terraform credentials, set KUBECONFIG |

## Secrets

Everything secret lives in Git, encrypted with SOPS + age. Two keys:

- **Personal key** (PC only): decrypts everything, including Terraform credentials.
- **Cluster key** (Secret `argocd/sops-age`): decrypts only Kubernetes Secrets.
  Argo CD's repo-server uses it through [KSOPS](https://github.com/viaduct-ai/kustomize-sops)
  at render time, so Secrets deploy from Git like any other manifest.

To add a Secret: write it as `secrets/<name>.enc.yaml`, `sops --encrypt --in-place` it,
and list it in a KSOPS generator (example: `apps/cert-manager/manifests/secret-generator.yaml`).
The cluster key itself is the one Secret applied by hand (`runbooks/rebuild-node.md`).

App repos keep their own Secrets next to their manifests, encrypted for the same two keys
(example: [duit](https://github.com/Qyang04/duit) `.sops.yaml` and `deploy/overlays/staging/secrets.enc.yaml`).
Every Application that deploys Secrets uses `ServerSideApply=true`: client-side apply would copy
the plaintext into a `last-applied-configuration` annotation.
