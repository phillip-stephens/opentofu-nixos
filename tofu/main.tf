terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Optional: uncomment to store state in S3
  # backend "s3" {
  #   bucket = "your-tfstate-bucket"
  #   key    = "nixos-aws/terraform.tfstate"
  #   region = var.aws_region
  # }
}

provider "aws" {
  region = var.aws_region
}

# ── Data: latest NixOS AMI ────────────────────────────────────────────────────
data "aws_ami" "nixos" {
  owners      = ["427812963091"]
  most_recent = true

  filter {
    name   = "name"
    values = ["nixos/25.11*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

# ── SSH key pair ──────────────────────────────────────────────────────────────
resource "aws_key_pair" "nixos" {
  key_name   = "${var.name}-key"
  public_key = var.ssh_public_key
}

# ── VPC & networking ──────────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, { Name = "${var.name}-vpc" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.common_tags, { Name = "${var.name}-igw" })
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = merge(local.common_tags, { Name = "${var.name}-subnet" })
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, { Name = "${var.name}-rt" })
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# ── Security group ────────────────────────────────────────────────────────────
resource "aws_security_group" "nixos" {
  name        = "${var.name}-sg"
  description = "NixOS VM - SSH only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name}-sg" })
}

# ── Persistent data EBS volume ────────────────────────────────────────────────
resource "aws_ebs_volume" "data" {
  availability_zone = "${var.aws_region}a"
  size              = var.data_volume_gb
  type              = "gp3"
  encrypted         = true

  tags = merge(local.common_tags, { Name = "${var.name}-data" })

  # Prevent accidental destruction of data volume
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_volume_attachment" "data" {
  count       = var.instance_stopped ? 0 : 1
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.nixos.id

  # Detach cleanly before destroy
  force_detach = true
  skip_destroy = false
}

# ── EC2 instance ──────────────────────────────────────────────────────────────
resource "aws_instance" "nixos" {
  ami                    = data.aws_ami.nixos.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.nixos.id]
  key_name               = aws_key_pair.nixos.key_name

  root_block_device {
    volume_size           = var.root_volume_gb
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # Upload the NixOS config directory and apply it on first boot
  user_data = <<-EOF
    #!/usr/bin/env bash
    set -euo pipefail

    # Wait for network
    until ping -c1 1.1.1.1 &>/dev/null; do sleep 2; done

    # Mount data volume (format on first boot only)
    DATA_DEV=/dev/xvdf
    DATA_MOUNT=/data
    if ! blkid "$DATA_DEV"; then
      mkfs.ext4 -L data "$DATA_DEV"
    fi
    mkdir -p "$DATA_MOUNT"
    mount "$DATA_DEV" "$DATA_MOUNT"
    echo "LABEL=data $DATA_MOUNT ext4 defaults 0 2" >> /etc/fstab
  EOF

  tags = merge(local.common_tags, { Name = var.name })

  lifecycle {
    # AMI may update; ignore to avoid unplanned replacement
    ignore_changes = [ami]
  }
}

# ── NixOS config deployment (null_resource) ───────────────────────────────────
resource "null_resource" "nixos_deploy" {
  count = var.instance_stopped ? 0 : 1

  triggers = {
    # Re-run whenever any nix config file changes
    config_hash = sha256(join("", [
      for f in fileset("${path.module}/../nixos", "**") :
      filesha256("${path.module}/../nixos/${f}")
    ]))
    instance_id = aws_instance.nixos.id
  }

  connection {
    type    = "ssh"
    host    = aws_instance.nixos.public_ip
    user    = "root"
    agent   = true
    timeout = "5m"
  }

  # Copy nixos config files
  provisioner "file" {
    source      = "${path.module}/../nixos/"
    destination = "/etc/nixos/"
  }

  # Apply the configuration
  provisioner "remote-exec" {
    inline = [
      "nixos-rebuild switch 2>&1 | tail -20"
    ]
  }

  depends_on = [aws_instance.nixos]
}
