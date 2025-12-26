locals {
  name_prefix = "${var.project_name}-${var.environment}"
  sagemaker_endpoint_name = "${local.name_prefix}-endpoint"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

