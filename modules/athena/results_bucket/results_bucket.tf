# # Build an AWS S3 bucket for Athena results
# resource "aws_s3_bucket" "athena_results_bucket" {
#   bucket = var.athena_results_bucket
#   acl    = "private"
#   policy = <<EOT
# {
#   "Id": "SIDataBucketPolicy",
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "lambda",
#       "Action": [
#         "s3:PutObject"
#       ],
#       "Effect": "Allow",
#       "Resource": [
#         "arn:aws:s3:::shooting-insights-athena-results/*"
#       ],
#       "Principal": {
#         "AWS": [
#           "arn:aws:iam::272773485930:role/collection_lambda_role",
#           "arn:aws:iam::272773485930:role/processing_lambda_role"
#         ]
#       }
#     }
#   ]
# }
#   EOT

#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }

# # Allow S3 Trigger of the Response Lambda

# resource "aws_lambda_permission" "allow_bucket" {
#   statement_id  = "AllowExecutionFromS3Bucket"
#   action        = "lambda:InvokeFunction"
#   function_name = "arn:aws:lambda:us-east-1:272773485930:function:response"
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.athena_results_bucket.arn
# }

# # Trigger for response to be ignited once all processing is complete
# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = aws_s3_bucket.athena_results_bucket.id

#   lambda_function {
#     lambda_function_arn = "arn:aws:lambda:us-east-1:272773485930:function:response"
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "total_made_each_spot_query/"
#     filter_suffix       = ".csv"
#   }

#   depends_on = [aws_lambda_permission.allow_bucket]
# }

# output "athena_results_bucket_name" {
#   value = aws_s3_bucket.athena_results_bucket.bucket
# }

# output "athena_results_bucket_arn" {
#   value = aws_s3_bucket.athena_results_bucket.arn
# }