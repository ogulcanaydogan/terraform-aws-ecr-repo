# terraform-aws-ecr-repo

Terraform module that creates an AWS Elastic Container Registry (ECR) repository with configurable encryption, lifecycle policies, repository policies, and image scanning.

## Features

- **Image tag immutability** - IMMUTABLE by default for production safety
- **Image scanning** - Scan on push enabled by default
- **KMS encryption** - Support for customer-managed KMS keys
- **Lifecycle policies** - Built-in default policy or custom JSON
- **Repository policies** - Easy IAM principal access control
- **Cross-account access** - Simple cross-account pull configuration
- **Input validation** - Comprehensive validation for all inputs

## Usage

### Basic Example

```hcl
module "ecr" {
  source = "ogulcanaydogan/ecr-repo/aws"

  name = "my-application"

  tags = {
    Environment = "production"
  }
}
```

### With Lifecycle Policy (Default)

```hcl
module "ecr" {
  source = "ogulcanaydogan/ecr-repo/aws"

  name = "my-application"

  # Enable default lifecycle policy
  enable_lifecycle_policy    = true
  keep_image_count           = 30      # Keep last 30 tagged images
  expire_untagged_after_days = 14      # Expire untagged after 14 days

  tags = {
    Environment = "production"
  }
}
```

### With Custom Lifecycle Policy

```hcl
module "ecr" {
  source = "ogulcanaydogan/ecr-repo/aws"

  name = "my-application"

  enable_lifecycle_policy = true
  lifecycle_policy_json   = <<-EOT
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Keep only the last 10 images",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 10
          },
          "action": { "type": "expire" }
        }
      ]
    }
  EOT
}
```

### With KMS Encryption

```hcl
module "ecr" {
  source = "ogulcanaydogan/ecr-repo/aws"

  name = "my-application"

  encryption_type = "KMS"
  kms_key_arn     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
}
```

### With Repository Policy (IAM Access Control)

```hcl
module "ecr" {
  source = "ogulcanaydogan/ecr-repo/aws"

  name = "my-application"

  # Grant pull access to specific IAM roles
  repository_read_access_arns = [
    "arn:aws:iam::123456789012:role/ECSTaskRole",
    "arn:aws:iam::123456789012:role/LambdaRole"
  ]

  # Grant push/pull access to CI/CD role
  repository_read_write_access_arns = [
    "arn:aws:iam::123456789012:role/CICDRole"
  ]
}
```

### With Cross-Account Access

```hcl
module "ecr" {
  source = "ogulcanaydogan/ecr-repo/aws"

  name = "shared-application"

  # Allow other AWS accounts to pull images
  cross_account_access_arns = [
    "arn:aws:iam::111111111111:root",
    "arn:aws:iam::222222222222:root"
  ]
}
```

### With Custom Repository Policy

```hcl
module "ecr" {
  source = "ogulcanaydogan/ecr-repo/aws"

  name = "my-application"

  create_repository_policy = true
  repository_policy_json   = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowPull",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::123456789012:role/MyRole"
          },
          "Action": [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage"
          ]
        }
      ]
    }
  EOT
}
```

### Mutable Tags (Development)

```hcl
module "ecr" {
  source = "ogulcanaydogan/ecr-repo/aws"

  name = "my-dev-application"

  # Allow tag overwriting for development
  image_tag_mutability = "MUTABLE"

  tags = {
    Environment = "development"
  }
}
```

## Inputs

### Required

| Name | Description | Type |
|------|-------------|------|
| `name` | Name of the ECR repository | `string` |

### Repository Settings

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `image_tag_mutability` | Tag mutability setting (MUTABLE or IMMUTABLE) | `string` | `"IMMUTABLE"` |
| `scan_on_push` | Enable image scanning on push | `bool` | `true` |
| `force_delete` | Delete repository even if it contains images | `bool` | `false` |
| `tags` | Tags to apply to the repository | `map(string)` | `{}` |

### Encryption

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `encryption_type` | Encryption type (AES256 or KMS) | `string` | `"AES256"` |
| `kms_key_arn` | KMS key ARN for encryption (required when encryption_type is KMS) | `string` | `null` |

### Lifecycle Policy

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_lifecycle_policy` | Enable lifecycle policy | `bool` | `false` |
| `lifecycle_policy_json` | Custom lifecycle policy JSON | `string` | `null` |
| `keep_image_count` | Number of tagged images to keep (default policy) | `number` | `30` |
| `expire_untagged_after_days` | Days before untagged images expire (0 to disable) | `number` | `14` |

### Repository Policy

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `create_repository_policy` | Create a repository policy | `bool` | `false` |
| `repository_policy_json` | Custom repository policy JSON | `string` | `null` |
| `repository_read_access_arns` | IAM ARNs with pull access | `list(string)` | `[]` |
| `repository_read_write_access_arns` | IAM ARNs with push/pull access | `list(string)` | `[]` |
| `cross_account_access_arns` | AWS account ARNs for cross-account pull | `list(string)` | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| `repository_name` | Name of the ECR repository |
| `repository_arn` | ARN of the ECR repository |
| `repository_url` | Repository URL for docker push/pull |
| `repository_uri` | Full URI of the repository (alias) |
| `registry_id` | Registry ID (AWS account ID) |
| `encryption_type` | Encryption type used |
| `image_tag_mutability` | Image tag mutability setting |
| `lifecycle_policy_enabled` | Whether lifecycle policy is enabled |
| `repository_policy_enabled` | Whether repository policy is attached |

## Docker Commands

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Build and tag image
docker build -t my-application .
docker tag my-application:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-application:latest

# Push image
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-application:latest

# Pull image
docker pull 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-application:latest
```

## Security Considerations

- **IMMUTABLE tags** are the default and recommended for production to prevent tag overwriting
- **Image scanning** is enabled by default to detect vulnerabilities
- **KMS encryption** is recommended for sensitive workloads requiring customer-managed keys
- **Repository policies** should follow least-privilege principle
- **Cross-account access** should be carefully reviewed before enabling

## Examples

See [examples/basic](examples/basic) for a minimal configuration.
