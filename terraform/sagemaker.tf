resource "aws_sagemaker_model_package_group" "grange" {
  model_package_group_name        = "${local.name_prefix}-model-group"
  model_package_group_description = "Model package group for ${var.project_name}"
}

resource "aws_sagemaker_pipeline" "grange" {
  pipeline_name         = "${local.name_prefix}-pipeline"
  pipeline_display_name = "${var.project_name}-Pipeline"
  pipeline_description  = "ML pipeline for training and deploying ${var.project_name} model"
  role_arn              = aws_iam_role.sagemaker_execution.arn

  pipeline_definition = jsonencode({
    Version = "2020-12-01"

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
        Name      = "RegisterModel"
        Type      = "RegisterModel"
        DependsOn = ["TrainModel"]
        Arguments = {
          ModelPackageGroupName = aws_sagemaker_model_package_group.grange.model_package_group_name
          ModelApprovalStatus   = "Approved"
          InferenceSpecification = {
            Containers = [
              {
                Image = "${aws_ecr_repository.inference.repository_url}:latest"
                ModelDataUrl = {
                  "Get" = "Steps.TrainModel.ModelArtifacts.S3ModelArtifacts"
                }
              }
            ]
            SupportedContentTypes      = ["text/csv"]
            SupportedResponseMIMETypes = ["application/json"]
          }
        }
      },

      {
        Name      = "CreateModel"
        Type      = "Model"
        DependsOn = ["RegisterModel"]
        Arguments = {
          ExecutionRoleArn = aws_iam_role.sagemaker_execution.arn
          PrimaryContainer = {
            Image = "${aws_ecr_repository.inference.repository_url}:latest"
            ModelDataUrl = {
              "Get" = "Steps.TrainModel.ModelArtifacts.S3ModelArtifacts"
            }
          }
        }
      },

      {
        Name        = "DeployEndpoint"
        Type        = "Lambda"
        DependsOn   = ["CreateModel"]
        FunctionArn = aws_lambda_function.deploy_endpoint.arn
        Arguments = {
          "ModelName" : {
            "Get" : "Steps.CreateModel.ModelName"
          },
          "EndpointName" : local.sagemaker_endpoint_name,
        }
      }
    ]
  })

  depends_on = [
    aws_sagemaker_model_package_group.grange,
    aws_lambda_function.deploy_endpoint
  ]
}
