# Amazon Quicksight Visualization
resource "aws_quicksight_data_source" "default" {
  data_source_id = "S3"
  name           = "Shooting Drill Data in S3"

  parameters {
    s3 {
      manifest_file_location {
        bucket = "shooting-insights-data"
        key    = "config/quicksight_manifest.json"
      }
    }
  }

  type = "S3"
}

data "archive_file" "quicksight_manifest" {
  type        = "json"
  source_file = "${path.module}/quicksight_manifest.json"
  output_path = "${path.module}/quicksight_manifest.json"
}