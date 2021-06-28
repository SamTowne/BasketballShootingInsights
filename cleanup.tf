module "cleanup_lambda" {
  source              = "./modules/lambda"
  role                = "cleanup_lambda_role"
  filename            = module.cleanup_lambda.output_path
  function_name       = "cleanup"
  handler             = "cleanup.lambda_handler"
  runtime             = "python3.8"
  source_code_hash    = filebase64sha256(module.cleanup_lambda.output_path)

  lambda_policy_json  = <<EOT
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
      },
      {
          "Effect": "Allow",
          "Action": [
              "s3:ListBucket",
              "s3:DeleteObject"
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