resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = var.enable_lifecycle_policy ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = var.lifecycle_policy_json
}
