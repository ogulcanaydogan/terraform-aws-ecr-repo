# Terraform AWS ECR Repository Module

Terraform module that creates an AWS Elastic Container Registry (ECR) repository with optional lifecycle policies and on-push image scanning. The module is ready for publication on the Terraform Registry.

## Features

- Configurable image tag mutability (`MUTABLE` or `IMMUTABLE`).
- Optional ECR basic image scanning on push.
- Optional lifecycle policy with JSON validation.
- Force delete support for cleaning up repositories containing images.

## Usage

```hcl
module "ecr" {
  source = "github.com/example-org/terraform-aws-ecr-repo"

  name = "my-ecr-repo"
}
```

### Lifecycle policy example

```hcl
module "ecr" {
  source = "github.com/example-org/terraform-aws-ecr-repo"

  name                     = "my-ecr-repo"
  enable_lifecycle_policy  = true
  lifecycle_policy_json    = <<-EOT
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

## Examples

See [examples/basic](examples/basic) for a minimal configuration.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| name | Name of the ECR repository. | string | n/a | yes |
| tags | Tags to apply to the repository. | map(string) | `{}` | no |
| image_tag_mutability | The tag mutability setting for the repository. | string | `"MUTABLE"` | no |
| scan_on_push | Indicates whether images are scanned after being pushed to the repository (ECR basic scanning). | bool | `true` | no |
| force_delete | If true, deletes the repository even if it contains images. | bool | `false` | no |
| enable_lifecycle_policy | Whether to create a lifecycle policy for the repository. | bool | `false` | no |
| lifecycle_policy_json | Lifecycle policy document to apply when enable_lifecycle_policy is true. | string | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| repository_name | Name of the ECR repository. |
| repository_arn | ARN of the ECR repository. |
| repository_url | Repository URI that can be used for docker push/pull. |
| registry_id | Registry ID where the repository was created. |
