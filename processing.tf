##################
### Processing ###
##################

module "athena_db_hello_world" {
  source = "./modules/athena/database"
  athena_db_name = "hello_world"
  athena_bucket_name = "shooting-insights-data"
  athena_workgroup_name = "hello_world"
}

#TODO: 
# - add permissions to lambda role so it can call athena
# - run a create table hello world
# - run a query hello world

module "athena_query_hello_world" {
  source = "./modules/athena/query"
  athena_query_name = "hello_world"
  athena_db_name = module.athena_db_hello_world.athena_db_name_output
  athena_workgroup_name = module.athena_db_hello_world.athena_workgroup_output
  athena_query = <<EOT
  CREATE EXTERNAL TABLE IF NOT EXISTS ${module.athena_db_hello_world.athena_db_name_output}.hello_world (
         `spot_1` int,
         `spot_2` int,
         `spot_3` int,
         `spot_4` int,
         `spot_5` int,
         `spot_6` int,
         `spot_7` int,
         `spot_8` int,
         `spot_9` int,
         `spot_10` int,
         `spot_11` int,
         `temp` int,
         `date` date,
         `time` string 
) 
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
         'serialization.format' = '1' ) LOCATION 's3://shooting-insights-data/test/' TBLPROPERTIES ('has_encrypted_data'='false');

  EOT
}
