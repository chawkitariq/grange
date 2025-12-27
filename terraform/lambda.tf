# Lambda Function for Endpoint Deployment
data "archive_file" "deploy_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/deploy"
  output_path = "${path.module}/../lambdas/deploy/lambda_handler.zip"
}

resource "aws_lambda_function" "deploy_endpoint" {
  filename      = data.archive_file.deploy_lambda.output_path
  function_name = "${local.name_prefix}-deploy-endpoint"
  role          = aws_iam_role.lambda_deploy.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = 900
}

