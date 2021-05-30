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

## Build an S3 bucket and DynamoDB for Terraform state and locking
module "bootstrap" {
  source                  = "./modules/bootstrap"
  s3_tfstate_bucket       = "shooting-insights-terraform-tfstate"
  s3_logging_bucket_name  = "shooting-insights-logging-bucket"
  dynamo_db_table_name    = "shooting-insights-dynamodb-terraform-locking"
}

module "lambda" {
  source = "./modules/lambda"
  lambda_role_name           = "shooting_insights_lambda_role"
  lambda_function_file_name  = "./modules/lambda/files/lambda_test/lambda_test.zip"
  lambda_function_name       = "lambda_test"
  lambda_function_handler    = "./modules/lambda/files/lambda_test/lambda_test.py"
  lambda_function_runtime    = "python3.8"

  lambda_policy_json                   = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": "*"
      }
  ]
}
EOT
}