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
  tfstate_bucket          = "shooting-insights-terraform-tfstate"
  logging_bucket          = "shooting-insights-logging-bucket"
  data_bucket             = "shooting-insights-data"
  tf_lock_dynamo_table    = "shooting-insights-dynamodb-terraform-locking"
}

module "submit_lambda" {
  source              = "./modules/lambda"
  role                = "submit_lambda_role"
  filename            = module.submit_lambda.output_path
  function_name       = "submit"
  handler             = "submit.lambda_handler"
  runtime             = "python3.8"
  source_code_hash    = filebase64sha256(module.submit_lambda.output_path)

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
              "${module.bootstrap.data_bucket_arn}"
          ]
      }      
  ]
}
EOT
}

module "api_gateway" {
  source            = "./modules/api_gateway"
  name              = "shooting_insights"
  protocol_type     = "HTTP"
  route_key         = "POST /si/submit"
  target            = module.submit_lambda.output_arn
  lambda_arn        = module.submit_lambda.output_arn
  lambda_invoke_arn = module.submit_lambda.output_invoke_arn
}
