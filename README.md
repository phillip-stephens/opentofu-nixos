# nixos-aws

NixOS on AWS EC2, managed with OpenTofu.

```
nixos-aws/
├── Makefile              ← make up / down / destroy
├── nixos/                ← NixOS configuration (pushed to the VM)
│   ├── configuration.nix
│   ├── hardware.nix
│   ├── networking.nix
│   ├── packages.nix
│   └── users.nix
└── tofu/                 ← OpenTofu infrastructure
    ├── main.tf
    ├── variables.tf
    ├── locals.tf
    ├── outputs.tf
    └── terraform.tfvars.example
```

---

## Prerequisites

| Tool | Install |
|------|---------|
| [OpenTofu](https://opentofu.org/docs/intro/install/) | `brew install opentofu` |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | `brew install awscli` |
| AWS credentials | `aws configure` or env vars |
| SSH key pair | `ssh-keygen -t ed25519` |

---

## Quick start

### 1. Configure

```bash
cp tofu/terraform.tfvars.example tofu/terraform.tfvars
```

Edit `tofu/terraform.tfvars`:

```hcl
ssh_public_key       = "ssh-ed25519 AAAA...  you@host"   # your public key
ssh_private_key_path = "~/.ssh/id_ed25519"               # matching private key
aws_region           = "us-east-1"
```

### 2. Add your SSH key to NixOS config

Open `nixos/users.nix` and paste your public key:

```nix
openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... you@host"
];
```

### 3. Deploy

```bash
make up
```

This will:
1. Initialise OpenTofu providers
2. Create VPC, subnet, security group, EBS volumes, and EC2 instance
3. Push `nixos/` to `/etc/nixos/` on the VM via SSH
4. Run `nixos-rebuild switch` on the VM
5. Print your SSH command

---

## Day-to-day commands

| Command | What it does |
|---------|-------------|
| `make up` | Deploy / re-deploy (also pushes config changes) |
| `make down` | Terminate the EC2 instance; **data EBS volume is kept** |
| `make destroy` | Delete **everything** including the data volume |

### Iterate on NixOS config

Edit any file under `nixos/`, then re-run:

```bash
make up
```

OpenTofu detects the config hash changed and re-runs `nixos-rebuild switch`.

### SSH manually

```bash
ssh -i ~/.ssh/id_ed25519 admin@<public-ip>
```

The IP is shown after `make up`, or via:

```bash
cd tofu && tofu output ssh_command
```

---

## Architecture

```
Internet
   │  port 22 only
   ▼
[Security Group]
   │
[EC2 t3.small]  ──  root gp3 EBS (20 GiB, deleted on terminate)
   │
   └──  data gp3 EBS (20 GiB, encrypted, persistent across make down)
```

- Root volume: ephemeral, deleted when the instance is terminated.
- Data volume (`/data`): persistent, survives `make down`, only removed with `make destroy`.

---

## Customisation

| What | Where |
|------|-------|
| System packages | `nixos/packages.nix` |
| SSH settings | `nixos/networking.nix` |
| Users / SSH keys | `nixos/users.nix` |
| Instance type / region | `tofu/terraform.tfvars` |
| Open extra ports | `nixos/networking.nix` + `tofu/main.tf` security group |

---

## Security notes

- Restrict `ssh_allowed_cidrs` to your own IP in `terraform.tfvars` — the default `0.0.0.0/0` is convenient but exposes SSH globally.
- Root login and password auth are disabled.
- All EBS volumes are encrypted at rest.
