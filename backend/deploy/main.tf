provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_iam_role" "api_lambda" {
  name = "serverless-example-api"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "api_lambda" {
  name        = "serverless-example-api"
  path        = "/"
  description = "My api lambda policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-east-2::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.region}::log-group:/aws/lambda/${aws_lambda_function.api_lambda.function_name}:*"
            ]
        }
    ]
}
EOF
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.api_lambda.function_name}"
  principal = "apigateway.amazonaws.com"
  source_arn = "${data.terraform_remote_state.infra.outputs.apigw_restapi_execution_arn}/*/*/*"
}

resource "aws_lambda_function" "api_lambda" {
  filename = "../function.zip"
  function_name = "serverless-example-api"
  role = aws_iam_role.api_lambda.arn
  handler = "api.lambda_handler"
  runtime = "python3.7"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = data.terraform_remote_state.infra.outputs.apigw_restapi_id
  resource_id = data.terraform_remote_state.infra.outputs.apigw_restapi_proxy_resource_id
  http_method = "ANY"
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.api_lambda.arn}/invocations"

  request_parameters =  {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}