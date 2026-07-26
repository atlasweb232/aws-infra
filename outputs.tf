output "build_server_public_ip" {
  description = "Public IP of the build server"
  value       = aws_instance.build_server.public_ip
}

output "build_server_private_ip" {
  description = "Private IP of the build server"
  value       = aws_instance.build_server.private_ip
}

output "build_server_ssh_command" {
  description = "SSH command to connect as rakibm user"
  value       = "ssh -i ${var.key_path} rakibm@${aws_instance.build_server.public_ip}"
}

output "build_server_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.build_server.id
}

output "build_server_security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.build_server.id
}

output "build_server_iam_role" {
  description = "IAM role attached to the build server"
  value       = aws_iam_role.build_server_role.name
}

# Gitea outputs (if enabled)
output "gitea_public_ip" {
  description = "Public IP of the Gitea server"
  value       = var.enable_gitea ? aws_instance.gitea_server[0].public_ip : "Gitea not enabled"
}

output "gitea_url" {
  description = "Gitea web URL"
  value       = var.enable_gitea ? "http://${aws_instance.gitea_server[0].public_ip}:3000" : "Gitea not enabled"
}

output "gitea_ssh_command" {
  description = "SSH command to connect to Gitea server"
  value       = var.enable_gitea ? "ssh -i ${var.key_path} rakibm@${aws_instance.gitea_server[0].public_ip}" : "Gitea not enabled"
}

# GHES outputs (if enabled - requires uncommenting in main.tf)
output "ghes_public_ip" {
  description = "Public IP of the GHES server"
  value       = var.enable_ghes ? "GHES not enabled (uncomment in main.tf)" : "GHES not enabled"
}

output "ghes_url" {
  description = "GHES web URL"
  value       = var.enable_ghes ? "http://${aws_instance.ghes_server[0].public_ip}:3000" : "GHES not enabled"
}
