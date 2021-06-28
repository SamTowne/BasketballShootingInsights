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
              "ses:SendRawEmail"
          ],
          "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Resource": "${module.athena_results_bucket.athena_results_bucket_arn}"
      }
  ]
}
EOT
}