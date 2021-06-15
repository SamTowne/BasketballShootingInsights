/*

DDL
spot1 string, spot2 string, spot3 string, spot4 string, spot5 string, spot6 string, spot7 string, spot8 string, spot9 string, spot10 string, spot11 string, temp string, date string, time string

DB and TABLE

*/

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