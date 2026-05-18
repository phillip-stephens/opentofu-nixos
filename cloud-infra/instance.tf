data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-*-26.04-arm64-server-*"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availabilityZone"
    values = [var.availability_zone]
  }
}

resource "aws_security_group" "desktop" {
  name        = "cloud-desktop"
  description = "SSH inbound, all outbound"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-desktop"
  }
}

resource "aws_instance" "desktop" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.desktop.key_name
  subnet_id                   = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.desktop.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "cloud-desktop"
  }
}

resource "aws_eip" "desktop" {
  instance = aws_instance.desktop.id
  domain   = "vpc"

  tags = {
    Name = "cloud-desktop"
  }
}

resource "null_resource" "install_nixos" {
  depends_on = [
    aws_instance.desktop,
    aws_volume_attachment.home,
    aws_eip.desktop,
  ]

  triggers = {
    instance_id = aws_instance.desktop.id
    flake_ref   = var.nixos_flake_ref
  }

  provisioner "local-exec" {
    command = <<-EOT
      nix run github:nix-community/nixos-anywhere -- \
        --flake '${var.nixos_flake_ref}' \
        ubuntu@${aws_eip.desktop.public_ip}
    EOT
  }
}
