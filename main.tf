resource "aws_ecr_repository" "default" {
  count = var.enabled ? 1 : 0
  name  = var.use_fullname ? module.label.id : module.label.name
  tags  = module.label.tags
}

resource "aws_ecr_lifecycle_policy" "default" {
  count      = var.enabled ? 1 : 0
  repository = join("", aws_ecr_repository.default.*.name)

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Remove untagged images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Rotate images when reach ${var.max_image_count} images stored",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": ${var.max_image_count}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "empty" {
  count = var.enabled ? 1 : 0
}

