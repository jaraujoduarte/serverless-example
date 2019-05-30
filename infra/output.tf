output "apigw_restapi_execution_arn" {
  value = aws_api_gateway_rest_api.serverless_example.execution_arn
}

output "apigw_restapi_id" {
  value = aws_api_gateway_rest_api.serverless_example.id
}

output "apigw_restapi_root_resource_id" {
  value = aws_api_gateway_rest_api.serverless_example.root_resource_id
}
