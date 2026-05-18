resource "aws_key_pair" "desktop" {
  key_name   = "cloud-desktop"
  public_key = var.ssh_public_key
}
