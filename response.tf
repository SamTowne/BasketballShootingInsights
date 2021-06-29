module "response_lambda" {
  source              = "./modules/lambda"
  role                = "response_lambda_role"
  filename            = module.response_lambda.output_path
  function_name       = "response"
  handler             = "response.lambda_handler"
  runtime             = "python3.8"
  source_code_hash    = filebase64sha256(module.response_lambda.output_path)

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
              "ses:SendRawEmail",
              "lambda:InvokeFunction",
              "athena:GetQueryResults"
          ],
          "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Resource": "${module.athena_results_bucket.athena_results_bucket_arn}"
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetBucketLocation",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:ListBucketMultipartUploads",
              "s3:AbortMultipartUpload",
              "s3:PutObject",
              "s3:ListMultipartUploadParts"
          ],
          "Resource": [
              "${module.bootstrap.data_bucket_arn}",
              "${module.bootstrap.data_bucket_arn}/*",
              "${module.athena_results_bucket.athena_results_bucket_arn}",
              "${module.athena_results_bucket.athena_results_bucket_arn}/*"
          ]
      }
  ]
}
EOT
}