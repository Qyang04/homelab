# Loads the SOPS-encrypted Terraform credentials into this PowerShell session.
# Usage (note the leading dot, so the variables stay in your session):
#   . .\scripts\load-secrets.ps1
# Needs your age private key at %AppData%\sops\age\keys.txt.

$file = Join-Path $PSScriptRoot "..\secrets\terraform.enc.env"
$lines = sops --decrypt $file
if ($LASTEXITCODE -ne 0) { throw "sops could not decrypt $file" }

$count = 0
foreach ($line in $lines) {
  if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$') {
    Set-Item -Path "env:$($Matches[1])" -Value $Matches[2]
    $count++
  }
}
# kubectl/helm talk to the homelab cluster over Tailscale (file kept outside the repo).
$env:KUBECONFIG = Join-Path $HOME ".kube\homelab.yaml"
# Prefer the winget kubectl (matches the cluster) over Docker Desktop's older one.
$env:Path = (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links") + ";" + $env:Path

Write-Host "KUBECONFIG -> $env:KUBECONFIG"
Write-Host "Loaded $count secrets into this session (names only):"
$lines | ForEach-Object { if ($_ -match '^\s*([A-Za-z_][A-Za-z0-9_]*)=') { "  $($Matches[1])" } }
