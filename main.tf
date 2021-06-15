#################
### Bootstrap ###
#################

## Build an S3 bucket and DynamoDB for Terraform state and locking
module "bootstrap" {
  source                  = "./modules/bootstrap"
  tfstate_bucket          = "shooting-insights-terraform-tfstate"
  logging_bucket          = "shooting-insights-logging-bucket"
  data_bucket             = "shooting-insights-data"
  tf_lock_dynamo_table    = "shooting-insights-dynamodb-terraform-locking"
}

############################
### Terraform S3 Backend ###
############################

terraform {
  backend "s3" {
    bucket         = "shooting-insights-terraform-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shooting-insights-dynamodb-terraform-locking"
    encrypt        = true
  }
}

#################
### Providers ###
#################

# Credentials are exported

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

provider "google" {
  project = "shooting_insights"
  region  = "us-west1"
  zone    = "us-west1-b"
}
