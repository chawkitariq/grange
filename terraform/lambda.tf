data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/predict"
  output_path = "${path.module}/../lambdas/predict/lambda_handler.zip"
}

resource "aws_lambda_function" "predict" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${local.name_prefix}-predict"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 256

  environment {
    variables = {
      SAGEMAKER_ENDPOINT_NAME = local.sagemaker_endpoint_name
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_execution,
    aws_cloudwatch_log_group.lambda
  ]
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.predict.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

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

