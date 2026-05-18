output "instance_ip" {
  description = "Public IPv4 address of the cloud desktop (Elastic IP)"
  value       = aws_eip.desktop.public_ip
}

output "instance_id" {
  description = "AWS EC2 instance ID"
  value       = aws_instance.desktop.id
}

output "home_volume_id" {
  description = "ID of the persistent home EBS volume"
  value       = aws_ebs_volume.home.id
}

output "home_volume_name" {
  description = "Name of the persistent home EBS volume"
  value       = "cloud-desktop-home"
}

output "ssh_command" {
  description = "SSH command to connect to the desktop (Ubuntu base image)"
  value       = "ssh ubuntu@${aws_eip.desktop.public_ip}"
}
