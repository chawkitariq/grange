# resource "aws_sagemaker_endpoint_configuration" "grange_serverless" {
#   name = "${local.name_prefix}-serverless-config"
#   production_variants {
#     variant_name = "AllTraffic"
#     model_name   = "${local.name_prefix}-model"
#     serverless_config {
#       memory_size_in_mb = 2048
#       max_concurrency   = 10
#     }
#   }
# }

# resource "aws_sagemaker_endpoint" "grange" {
#   name                 = "${local.name_prefix}-endpoint"
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.grange_serverless.name
# }

resource "aws_sagemaker_pipeline" "grange" {
  pipeline_name         = "${local.name_prefix}-pipeline"
  pipeline_display_name = "${var.project_name}-Pipeline"
  pipeline_description  = "ML pipeline for training and deploying ${var.project_name} model"
  role_arn              = aws_iam_role.sagemaker_execution.arn

  pipeline_definition = jsonencode({
    Version = "2020-12-01"
    Parameters = [
      {
        Name         = "ModelApprovalStatus"
        Type         = "String"
        DefaultValue = "PendingManualApproval"
      }
    ]
    Steps = [
      {
        Name = "TrainModel"
        Type = "Training"
        Arguments = {
          AlgorithmSpecification = {
            TrainingImage     = "${aws_ecr_repository.training.repository_url}:latest"
            TrainingInputMode = "File"
          }
          InputDataConfig = [
            {
              ChannelName = "train"
              DataSource = {
                S3DataSource = {
                  S3DataType             = "S3Prefix"
                  S3Uri                  = "s3://${aws_s3_bucket.ml_data.id}/input/"
                  S3DataDistributionType = "FullyReplicated"
                }
              }
              ContentType = "text/csv"
            }
          ]
          OutputDataConfig = {
            S3OutputPath = "s3://${aws_s3_bucket.ml_data.id}/output/"
          }
          ResourceConfig = {
            InstanceCount  = 1
            InstanceType   = var.training_instance_type
            VolumeSizeInGB = 10
          }
          RoleArn = aws_iam_role.sagemaker_execution.arn
          StoppingCondition = {
            MaxRuntimeInSeconds = 3600
          }
        }
      },
      {
        Name      = "CreateModel"
        Type      = "Model"
        Arguments = {
          ModelName        = var.sagemaker_model_name
          ExecutionRoleArn = aws_iam_role.sagemaker_execution.arn
          PrimaryContainer = {
            Image = "${aws_ecr_repository.inference.repository_url}:latest"
            ModelDataUrl = {
              "Get" = "Steps.TrainModel.ModelArtifacts.S3ModelArtifacts"
            }
          }
        }
      }
    ]
  })
}
