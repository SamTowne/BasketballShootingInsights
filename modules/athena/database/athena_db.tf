
resource "aws_athena_database" "athena_db" {
  name   = var.athena_db_name
  bucket = var.athena_bucket_name
}

resource "aws_athena_workgroup" "athena_workgroup" {
  name = var.athena_workgroup_name
}

output "athena_db_name_output" {
  value = aws_athena_database.athena_db.name
}

output "athena_workgroup_output"{
  value = aws_athena_workgroup.athena_workgroup.name
}