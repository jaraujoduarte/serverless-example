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
  name = "serverless-example-api"
  path = "/"
  description = "My api lambda policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:*:*:log-group:/aws/lambda/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:/aws/lambda/${aws_lambda_function.api_lambda.function_name}*"
            ]
        },
        {
            "Sid": "SpecificTable",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGet*",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:Get*",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWrite*",
                "dynamodb:CreateTable",
                "dynamodb:Delete*",
                "dynamodb:Update*",
                "dynamodb:PutItem"
            ],
            "Resource": [
              "arn:aws:dynamodb:*:*:table/movie",
              "arn:aws:dynamodb:*:*:table/rating"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "api_lambda" {
  role       = "${aws_iam_role.api_lambda.name}"
  policy_arn = "${aws_iam_policy.api_lambda.arn}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.api_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.terraform_remote_state.infra.outputs.apigw_restapi_execution_arn}/*/*/*"
}

resource "aws_lambda_function" "api_lambda" {
  filename         = "../api.zip"
  function_name    = "serverless-example-api"
  role             = aws_iam_role.api_lambda.arn
  handler          = "api.lambda_handler"
  runtime          = "python3.7"
  source_code_hash = "${filebase64sha256("../api.zip")}"
}

# API Gateway
resource "aws_api_gateway_resource" "serverless_example_proxy" {
  rest_api_id = data.terraform_remote_state.infra.outputs.apigw_restapi_id
  parent_id   = data.terraform_remote_state.infra.outputs.apigw_restapi_root_resource_id
  path_part   = "{proxy+}"
}

# API Gateway - options for preflight
resource "aws_api_gateway_method" "options_method" {
    rest_api_id   = data.terraform_remote_state.infra.outputs.apigw_restapi_id
    resource_id   = aws_api_gateway_resource.serverless_example_proxy.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
  depends_on  = ["aws_api_gateway_method.options_method"]
  rest_api_id = data.terraform_remote_state.infra.outputs.apigw_restapi_id
  resource_id = aws_api_gateway_resource.serverless_example_proxy.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_models = {
      "application/json" = "Empty"
  }

  response_parameters = {
      "method.response.header.Access-Control-Allow-Headers" = true,
      "method.response.header.Access-Control-Allow-Methods" = true,
      "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "options_integration" {
  depends_on = ["aws_api_gateway_method.options_method"]

  rest_api_id = data.terraform_remote_state.infra.outputs.apigw_restapi_id
  resource_id = aws_api_gateway_resource.serverless_example_proxy.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
resource "aws_api_gateway_integration_response" "options_integration_response" {
    lifecycle {
      create_before_destroy = true
    }
    rest_api_id = data.terraform_remote_state.infra.outputs.apigw_restapi_id
    resource_id = aws_api_gateway_resource.serverless_example_proxy.id
    http_method = aws_api_gateway_method.options_method.http_method
    status_code = aws_api_gateway_method_response.options_200.status_code

    response_templates = {
        "application/json" = "{\"statusCode\": 200}"
    }

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT '",
        "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    }
    depends_on = ["aws_api_gateway_method_response.options_200"]
}

# API Gateway - lambda integration
resource "aws_api_gateway_method" "serverless_example_proxy_any" {
  rest_api_id   = data.terraform_remote_state.infra.outputs.apigw_restapi_id
  resource_id   = aws_api_gateway_resource.serverless_example_proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "api_lambda_integration" {
  depends_on = ["aws_api_gateway_resource.serverless_example_proxy"]

  rest_api_id             = data.terraform_remote_state.infra.outputs.apigw_restapi_id
  resource_id             = aws_api_gateway_resource.serverless_example_proxy.id
  http_method             = "ANY"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.api_lambda.arn}/invocations"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "serverless_example_default" {
  depends_on = ["aws_api_gateway_integration.api_lambda_integration"]

  rest_api_id = data.terraform_remote_state.infra.outputs.apigw_restapi_id
  stage_name  = "default"
}
