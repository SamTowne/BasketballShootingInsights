#################
### Bootstrap ###
#################

# Build an S3 bucket and DynamoDB for Terraform state and locking
module "bootstrap" {
  source                  = "../modules/bootstrap"
  tfstate_bucket          = "shooting-insights-terraform-tfstate"
  data_bucket             = "shooting-insights-data"
  athena_results_bucket   = "shooting-insights-athena-results"
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

##################
### Collection ###
##################

# An Api Gateway receives Google Form post data
# A lambda function is triggered
# The lambda function stores the form data to an S3 bucket

module "collection" {
  source              = "../modules/collect"
  data_bucket_arn     = module.bootstrap.data_bucket_arn
}

##################
### Processing ###
##################

module "processing" {
  source              = "../modules/process"
  data_bucket_arn     = module.bootstrap.data_bucket_arn
}

################
### Response ###
################

module "response" {
  source                    = "../modules/respond"
  data_bucket_arn           = module.bootstrap.data_bucket_arn
  temp_bucket_arn           = module.collection.temp_bucket_arn
  athena_bucket_arn         = module.processing.athena_bucket_arn
}

###############
### Cleanup ###
###############

module "cleanup" {
  source = "../modules/clean"
  temp_bucket_arn           = module.collection.temp_bucket_arn
  athena_bucket_arn         = module.processing.athena_bucket_arn
  processing_bucket_arn     = module.processing.processing_bucket_arn
}