resource "aws_ebs_volume" "home" {
  availability_zone = var.availability_zone
  size              = var.home_volume_size
  type              = "gp3"

  tags = {
    Name = "cloud-desktop-home"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_volume_attachment" "home" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.home.id
  instance_id = aws_instance.desktop.id
}
