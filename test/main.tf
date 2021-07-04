####################
### Project Vars ###
####################

locals {
  project_name = "basketball-drill-bot-test"
  environment  = "test"
  region       = "us-west-1"
}

#################
### Bootstrap ###
#################

# Build an S3 bucket and DynamoDB for Terraform state and locking
module "bootstrap" {
  source                  = "../modules/bootstrap"
  tfstate_bucket          = "${local.project_name}-terraform-tfstate"
  data_bucket             = "${local.project_name}-data"
  athena_results_bucket   = "${local.project_name}-athena-results"
  tf_lock_dynamo_table    = "${local.project_name}-dynamodb-terraform-locking"
}

############################
### Terraform S3 Backend ###
############################

terraform {
  # Project variables must be hard coded here
  # backend "s3" {
  #   bucket         = "basketball-drill-bot-test-terraform-tfstate"
  #   key            = "terraform.tfstate"
  #   region         = "us-west-1"
  #   dynamodb_table = "basketball-drill-bot-test-dynamodb-terraform-locking"
  #   encrypt        = true
  # }
}

# #################
# ### Providers ###
# #################

# # Credentials are exported

# provider "aws" {
#   region  = local.region

#   default_tags {
#    tags = {
#      Terraform   = "true"
#      Environment = local.environment
#      Owner       = "Sam"
#      Project     = local.project_name
#    }
#  }
# }

# ##################
# ### Collection ###
# ##################

# # An Api Gateway receives Google Form post data
# # A lambda function is triggered
# # The lambda function stores the form data to an S3 bucket

# module "collection" {
#   source              = "../modules/collect"
#   data_bucket_arn     = module.bootstrap.data_bucket_arn
# }

# ##################
# ### Processing ###
# ##################

# module "processing" {
#   source              = "../modules/process"
#   data_bucket_arn     = module.bootstrap.data_bucket_arn
# }

# ################
# ### Response ###
# ################

# module "response" {
#   source                    = "../modules/respond"
#   data_bucket_arn           = module.bootstrap.data_bucket_arn
#   temp_bucket_arn           = module.collection.temp_bucket_arn
#   athena_bucket_arn         = module.processing.athena_bucket_arn
# }

# ###############
# ### Cleanup ###
# ###############

# module "cleanup" {
#   source = "../modules/clean"
#   temp_bucket_arn           = module.collection.temp_bucket_arn
#   athena_bucket_arn         = module.processing.athena_bucket_arn
#   processing_bucket_arn     = module.processing.processing_bucket_arn
# }