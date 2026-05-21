output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.nixos.id
}

output "public_ip" {
  description = "Public IP address of the NixOS VM"
  value       = aws_instance.nixos.public_ip
}

output "public_dns" {
  description = "Public DNS hostname of the NixOS VM"
  value       = aws_instance.nixos.public_dns
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh admin@${aws_instance.nixos.public_ip}"
}

output "data_volume_id" {
  description = "ID of the persistent data EBS volume"
  value       = aws_ebs_volume.data.id
}

output "ami_used" {
  description = "NixOS AMI that was selected"
  value       = data.aws_ami.nixos.id
}
