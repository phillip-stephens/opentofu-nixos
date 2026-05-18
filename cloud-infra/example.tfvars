# Copy this to terraform.tfvars (gitignored) and fill in real values,
# OR export as TF_VAR_* environment variables (preferred for secrets).

ssh_public_key = "ssh-ed25519 AAAA..."

# Optional overrides
# region            = "ap-southeast-2"   # Sydney AU — closest to NZ; no AWS NZ region exists
# availability_zone = "ap-southeast-2a"  # must be consistent across up/down cycles (EBS constraint)
# instance_type     = "m5.xlarge"        # 4 vCPU / 16 GB — change to m5.2xlarge for beefy
# home_volume_size  = 30
# nixos_flake_ref   = "github:youruser/nixos-config#cloud-desktop"
# tailscale_auth_key = "tskey-auth-..."
