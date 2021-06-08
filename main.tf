terraform {
  backend "s3" {
    bucket         = "shooting-insights-terraform-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shooting-insights-dynamodb-terraform-locking"
    encrypt        = true
  }
}

provider "aws" {
  region  = "us-east-1"

  default_tags {
   tags = {
     Terraform   = "true"
     Environment = "Test"
     Owner       = "Sam"
     Project     = "ShootingInsights"
   }
 }
}

# Credentials exported into desktop shell
provider "google" {
  project = "shooting_insights"
  region  = "us-west1"
  zone    = "us-west1-b"
}

## Build an S3 bucket and DynamoDB for Terraform state and locking
module "bootstrap" {
  source                  = "./modules/bootstrap"
  s3_tfstate_bucket       = "shooting-insights-terraform-tfstate"
  s3_logging_bucket_name  = "shooting-insights-logging-bucket"
  s3_data_bucket_name     = "shooting-insights-data"
  dynamo_db_table_name    = "shooting-insights-dynamodb-terraform-locking"
}

module "api_inbound_lambda" {
  source              = "./modules/lambda"
  role                = "api_inbound_lambda_role"
  filename            = module.api_inbound_lambda.output_path
  function_name       = "api_inbound"
  handler             = "api_inbound.lambda_handler"
  runtime             = "python3.8"
  source_code_hash    = filebase64sha256(module.api_inbound_lambda.output_path)

  lambda_policy_json  = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "ses:SendEmail",
              "ses:SendRawEmail"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:PutObject"
          ],
          "Resource": [
              "${module.bootstrap.s3_data_bucket_arn}"
          ]
      }      
  ]
}
EOT
}

module "api_gateway" {
  source        = "./modules/api_gateway"
  name          = "shooting_insights"
  protocol_type = "HTTP"
  route_key     = "POST /si/submit"
  target        = module.api_inbound_lambda.output_arn
}

# resource "aws_apigatewayv2_integration" "api_inbound_lambda_integration" {
#   api_id                    = module.api_gateway.api_id_output
#   integration_type          = "AWS_PROXY"
#   connection_type           = "INTERNET"
#   content_handling_strategy = "CONVERT_TO_TEXT"
#   description               = "Integrate api gateway with lambda function"
#   integration_method        = "POST"
#   integration_uri           = module.api_inbound_lambda.output_invoke_arn
#   passthrough_behavior      = "WHEN_NO_MATCH"
# }