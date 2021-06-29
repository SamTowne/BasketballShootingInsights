##################
### Collection ###
##################

# An Api Gateway receives Google Form post data
# A lambda function is triggered
# The lambda function stores the form data to an S3 bucket

module "collection" {
  source            = "./modules/collection"
  data_bucket_arn     = module.bootstrap.data_bucket_arn
}

# module "api_gateway" {
#   source            = "./modules/api_gateway"
#   name              = "shooting_insights"
#   protocol_type     = "HTTP"
#   route_key         = "POST /si/submit"
#   target            = module.collection_lambda.output_arn
#   lambda_arn        = module.collection_lambda.output_arn
#   lambda_invoke_arn = module.collection_lambda.output_invoke_arn
# }

# module "collection_lambda" {
#   source              = "./modules/lambda"
#   role                = "collection_lambda_role"
#   filename            = module.collection_lambda.output_path
#   function_name       = "collection"
#   handler             = "collection.lambda_handler"
#   runtime             = "python3.8"
#   source_code_hash    = filebase64sha256(module.collection_lambda.output_path)

#   lambda_policy_json  = <<EOT
# {
#   "Version": "2012-10-17",
#   "Statement": [
#       {
#           "Effect": "Allow",
#           "Action": [
#               "logs:CreateLogGroup",
#               "logs:CreateLogStream",
#               "logs:PutLogEvents",
#               "ses:SendEmail",
#               "ses:SendRawEmail",
#               "lambda:InvokeFunction"
#           ],
#           "Resource": "*"
#       },
#       {
#           "Effect": "Allow",
#           "Action": [
#               "s3:PutObject"
#           ],
#           "Resource": [
#               "${module.bootstrap.data_bucket_arn}"
#           ]
#       }
#   ]
# }
# EOT
# }
