variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "grange"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "training_instance_type" {
  description = "EC2 instance type for training jobs"
  type        = string
  default     = "ml.m5.large"
}
