variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-southeast-2"
}

variable "name" {
  description = "Resource name prefix"
  type        = string
  default     = "nixos-dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ssh_public_key" {
  description = "SSH public key to authorize on the instance"
  type        = string
  # Set via TF_VAR_ssh_public_key or terraform.tfvars
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to reach SSH (port 22). Restrict to your IP!"
  type        = list(string)
  default     = ["0.0.0.0/0"] # tighten this in production
}

variable "root_volume_gb" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "data_volume_gb" {
  description = "Persistent data EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "instance_stopped" {
  description = "Set to true with 'make down' to detach volumes without destroying them"
  type        = bool
  default     = false
}
