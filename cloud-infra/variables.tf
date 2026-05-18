variable "region" {
  description = "AWS region"
  default     = "ap-southeast-6"
}

variable "availability_zone" {
  description = "AZ for the instance and EBS volume — must match so the volume can always be reattached"
  default     = "ap-southeast-6a"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t4g.xlarge"
}

variable "home_volume_size" {
  description = "Size of the persistent home EBS volume in GB"
  default     = 50
}

variable "ssh_public_key" {
  description = "SSH public key to register and allow on the instance"
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFKKfkv3C6sDntua03IdR1jBxxvFSyfmq7MAPJ9i+rV stanford"
}

variable "nixos_flake_ref" {
  description = "Nix flake reference for nixos-anywhere to install"
  default     = "github:phillip-stephens/opentofu-nixos?dir=nix-os#default"
}

variable "tailscale_auth_key" {
  description = "Tailscale pre-auth key (used only during nixos-anywhere install)"
  sensitive   = true
  default     = ""
}
