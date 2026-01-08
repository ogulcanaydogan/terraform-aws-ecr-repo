output "repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.this.name
}

output "repository_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.this.arn
}

output "repository_url" {
  description = "Repository URL for docker push/pull commands."
  value       = aws_ecr_repository.this.repository_url
}

output "registry_id" {
  description = "Registry ID (AWS account ID) where the repository was created."
  value       = aws_ecr_repository.this.registry_id
}

output "repository_uri" {
  description = "Full URI of the repository (alias for repository_url)."
  value       = aws_ecr_repository.this.repository_url
}

output "encryption_type" {
  description = "Encryption type used for the repository."
  value       = var.encryption_type
}

output "image_tag_mutability" {
  description = "Image tag mutability setting for the repository."
  value       = aws_ecr_repository.this.image_tag_mutability
}

output "lifecycle_policy_enabled" {
  description = "Whether lifecycle policy is enabled."
  value       = var.enable_lifecycle_policy
}

output "repository_policy_enabled" {
  description = "Whether repository policy is attached."
  value       = local.create_policy && local.repository_policy != null
}
