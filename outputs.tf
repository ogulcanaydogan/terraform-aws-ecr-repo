output "repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.this.name
}

output "repository_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.this.arn
}

output "repository_url" {
  description = "Repository URI that can be used for docker push/pull."
  value       = aws_ecr_repository.this.repository_url
}

output "registry_id" {
  description = "Registry ID where the repository was created."
  value       = aws_ecr_repository.this.registry_id
}
