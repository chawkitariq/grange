data "aws_ecr_lifecycle_policy_document" "keep_last_10" {
  rule {
    priority = 1
    description   = "Keep last 10 images"

    selection {
      tag_status   = "any"
      count_type   = "imageCountMoreThan"
      count_number = 10
    }

    action {
      type = "expire"
    }
  }
}

# ECR Repository for Training Image
resource "aws_ecr_repository" "training" {
  name                 = "${var.project_name}-training"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "training" {
  repository = aws_ecr_repository.training.name
  policy     = data.aws_ecr_lifecycle_policy_document.keep_last_10.json
}

# ECR Repository for Inference Image
resource "aws_ecr_repository" "inference" {
  name                 = "${var.project_name}-inference"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "inference" {
  repository = aws_ecr_repository.inference.name
  policy     = data.aws_ecr_lifecycle_policy_document.keep_last_10.json
}
