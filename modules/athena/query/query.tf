resource "aws_athena_named_query" "athena_query" {
  name      = var.athena_query_name
  database  = var.athena_db_name
  query     = var.athena_query
  workgroup = var.athena_workgroup_name
}