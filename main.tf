terraform {
/*
  backend "s3" {
    bucket         = "shooting-insights-terraform-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "codebuild-dynamodb-terraform-locking"
    encrypt        = true
  }
*/
}

provider "aws" {
  region  = "us-east-1"
/*
  assume_role {
    # Remember to update this account ID to yours
    role_arn     = "arn:aws:iam::718626770228:role/TerraformAssumedIamRole"
    session_name = "terraform"
  }
*/
}

## Build an S3 bucket and DynamoDB for Terraform state and locking
module "bootstrap" {
  source                              = "./modules/bootstrap"
  s3_tfstate_bucket                   = "shooting-insights-terraform-tfstate"
  s3_logging_bucket_name              = "shooting-insights-logging-bucket"
  dynamo_db_table_name                = "shooting-insights-dynamodb-terraform-locking"
}