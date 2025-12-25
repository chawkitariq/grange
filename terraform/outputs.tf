output "ecr_training_repository_name" {
  description = "Name of the ECR repository for training images"
  value       = aws_ecr_repository.training.name
}

output "ecr_inference_repository_name" {
  description = "Name of the ECR repository for inference images"
  value       = aws_ecr_repository.inference.name
}

output "sagemaker_pipeline_name" {
  description = "Name of the SageMaker Pipeline"
  value       = aws_sagemaker_pipeline.grange.pipeline_name
}

output "sagemaker_endpoint_name" {
  description = "Name of the SageMaker Endpoint"
  value       = var.sagemaker_endpoint_name
}

output "sagemaker_model_name" {
  description = "Name of the SageMaker Model"
  value       = var.sagemaker_model_name
}