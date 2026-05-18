# cloud-infra

OpenTofu config for a spin-up/spin-down NixOS cloud desktop on AWS (Sydney, AU — closest region to NZ).

Manages infrastructure only — OS config lives in a separate `nixos-config` repo.

## What this creates

**Persistent (survives `make down`):**
- An EBS volume (`cloud-desktop-home`, gp3) used as `/home`
- An SSH keypair registered with AWS
- A security group allowing SSH inbound

**Ephemeral (created/destroyed on demand):**
- An EC2 instance (`m5.xlarge` by default — 4 vCPU, 16 GB RAM)
- An Elastic IP (static public IP — released on `make down`)
- Volume attachment
- NixOS install via nixos-anywhere

## Prerequisites

- [OpenTofu](https://opentofu.org) installed
- [Nix](https://nixos.org/download) installed (used by nixos-anywhere at apply time)
- An AWS account with programmatic access credentials

## First-time setup

**1. Create an IAM user** (or use an IAM role / SSO) with the following permissions:
- `AmazonEC2FullAccess` (or a scoped policy covering EC2, EBS, key pairs, security groups, and Elastic IPs)

**2. Get credentials** — either:
- Export `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as env vars (recommended), or
- Run `aws configure` to write `~/.aws/credentials`

**3. Create `config.tfvars`** in this directory (it's gitignored):

```hcl
ssh_public_key = "ssh-ed25519 AAAA..."  # contents of ~/.ssh/id_ed25519.pub
```

**4. Set the flake ref** if needed:

```hcl
nixos_flake_ref = "github:youruser/nixos-config#cloud-desktop"
```

**5. Initialise and apply:**

```bash
make init
make up
```

Tofu will provision the instance, attach the home volume, then run nixos-anywhere to install NixOS (~3-4 minutes total).

## Daily use

```bash
# Spin up
make up

# Spin up with more CPU/RAM for heavy work (m5.2xlarge: 8 vCPU, 32 GB RAM)
make up-beefy

# Get the instance IP
tofu output instance_ip

# SSH in (Ubuntu base image, before NixOS install)
ssh ubuntu@$(tofu output -raw instance_ip)

# SSH in (after NixOS install)
ssh you@$(tofu output -raw instance_ip)

# Tear down compute only — home volume is preserved
make down

# Full destroy including home volume — DATA LOSS, asks for confirmation
make down-full
```

## Updating the NixOS config

Push changes to your nixos-config repo, then on the running machine:

```bash
nixos-rebuild switch --flake github:youruser/nixos-config#cloud-desktop
```

To force a full reinstall via nixos-anywhere:

```bash
tofu taint null_resource.install_nixos && make up
```

## State

State is stored locally in `terraform.tfstate` (gitignored). Don't delete it. If you lose it, recover with `tofu import` — the EBS volume is visible in the EC2 console as `cloud-desktop-home`.

## Key constraints

- The EBS home volume has `prevent_destroy = true` — remove that lifecycle block before `make down-full` will succeed
- The `availability_zone` variable must stay consistent between up/down cycles — EBS volumes are AZ-local and can't be reattached across AZs
- Secrets go in `config.tfvars` (gitignored) or as `TF_VAR_*` / `AWS_*` env vars — never committed
- Port 3389 (RDP) is **not** open to the internet — only reachable via Tailscale
