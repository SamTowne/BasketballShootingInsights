resource "aws_apigatewayv2_api" "api_gateway" {
  name          = var.name
  protocol_type = var.protocol_type
  route_key     = var.route_key
  target        = var.target
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                    = aws_apigatewayv2_api.api_gateway.id
  integration_type          = "AWS_PROXY"
  description               = "Integrate api gateway with lambda function"
  integration_method        = "POST"
  integration_uri           = var.lambda_invoke_arn
  passthrough_behavior      = "WHEN_NO_MATCH"
}

resource "aws_lambda_permission" "api-gw" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = var.lambda_arn
    principal     = "apigateway.amazonaws.com"

    source_arn = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*/*"
}
