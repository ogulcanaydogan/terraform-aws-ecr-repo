locals {
  # Generate default lifecycle policy if custom one not provided
  default_lifecycle_policy = jsonencode({
    rules = concat(
      # Rule 1: Keep last N tagged images
      [{
        rulePriority = 1
        description  = "Keep last ${var.keep_image_count} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "latest", "release", "main", "master"]
          countType     = "imageCountMoreThan"
          countNumber   = var.keep_image_count
        }
        action = {
          type = "expire"
        }
      }],
      # Rule 2: Expire untagged images (if enabled)
      var.expire_untagged_after_days > 0 ? [{
        rulePriority = 2
        description  = "Expire untagged images after ${var.expire_untagged_after_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.expire_untagged_after_days
        }
        action = {
          type = "expire"
        }
      }] : []
    )
  })

  # Use custom policy if provided, otherwise use default
  lifecycle_policy = var.lifecycle_policy_json != null ? var.lifecycle_policy_json : local.default_lifecycle_policy

  # Determine if we need to create a repository policy
  create_policy = var.create_repository_policy || var.repository_policy_json != null || length(var.repository_read_access_arns) > 0 || length(var.repository_read_write_access_arns) > 0 || length(var.cross_account_access_arns) > 0

  # Build repository policy from access ARNs if custom policy not provided
  generated_policy_statements = concat(
    # Read-only access
    length(var.repository_read_access_arns) > 0 ? [{
      Sid    = "AllowPull"
      Effect = "Allow"
      Principal = {
        AWS = var.repository_read_access_arns
      }
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }] : [],
    # Read-write access
    length(var.repository_read_write_access_arns) > 0 ? [{
      Sid    = "AllowPushPull"
      Effect = "Allow"
      Principal = {
        AWS = var.repository_read_write_access_arns
      }
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ]
    }] : [],
    # Cross-account access
    length(var.cross_account_access_arns) > 0 ? [{
      Sid    = "AllowCrossAccountPull"
      Effect = "Allow"
      Principal = {
        AWS = var.cross_account_access_arns
      }
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }] : []
  )

  generated_policy = length(local.generated_policy_statements) > 0 ? jsonencode({
    Version   = "2012-10-17"
    Statement = local.generated_policy_statements
  }) : null

  repository_policy = var.repository_policy_json != null ? var.repository_policy_json : local.generated_policy
}

resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = var.enable_lifecycle_policy ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = local.lifecycle_policy
}

resource "aws_ecr_repository_policy" "this" {
  count = local.create_policy && local.repository_policy != null ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = local.repository_policy
}
