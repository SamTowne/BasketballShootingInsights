resource "aws_apigatewayv2_api" "api_gateway" {
  name          = var.name
  protocol_type = var.protocol_type
  route_key     = var.route_key
  target        = var.target
}

output "api_id_output" {
  value = aws_apigatewayv2_api.api_gateway.id
}