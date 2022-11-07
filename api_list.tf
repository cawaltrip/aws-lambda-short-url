resource "aws_api_gateway_method" "short_url_api_get" {
  rest_api_id      = aws_api_gateway_rest_api.short_urls_api_gateway.id
  resource_id      = aws_api_gateway_resource.short_url_api_resource_admin.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "short_url_api_get_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.short_urls_api_gateway.id
  resource_id             = aws_api_gateway_resource.short_url_api_resource_admin.id
  http_method             = aws_api_gateway_method.short_url_api_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.short_url_list.arn}/invocations"
}
