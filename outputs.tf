# =============================================================================
# Atlas Infrastructure - Outputs
# =============================================================================

output "atlas_server_public_ip" {
  description = "Public IP address of the Atlas server"
  value       = aws_instance.atlas_server.public_ip
}

output "atlas_server_private_ip" {
  description = "Private IP address of the Atlas server"
  value       = aws_instance.atlas_server.private_ip
}

output "atlas_server_ssh_command" {
  description = "SSH command to connect to the Atlas server"
  value       = "ssh -i ~/.ssh/atlas-keypair.pem rakibm@${aws_instance.atlas_server.public_ip}"
}

output "atlas_server_instance_id" {
  description = "Instance ID of the Atlas server"
  value       = aws_instance.atlas_server.id
}

output "atlas_server_security_group_id" {
  description = "Security group ID for the Atlas server"
  value       = aws_security_group.atlas_server.id
}

output "ghes_url" {
  description = "URL to access GitHub Enterprise Server"
  value       = "http://${aws_instance.atlas_server.public_ip}"
}
