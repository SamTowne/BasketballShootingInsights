import json
import boto3

def lambda_handler(event, context):
    ### Setup Athena Query

    athena_client = boto3.client('athena')
    api_route = event['api_route']
    table_name = api_route.replace("/","")

    params = {
    'region': 'us-east-1',
    'database': 'shooting_insights',
    'bucket': 'shooting-insights-setup-processing-results',
    'create_table_query': 
    """
    CREATE EXTERNAL TABLE IF NOT EXISTS {_table_name} (
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
         'serialization.format' = '1' ) LOCATION 's3://shooting-insights-data/collection{_api_route}/' TBLPROPERTIES ('has_encrypted_data'='false');
    """.format(_api_route=api_route,_table_name= table_name)
    }

    create_table_query_response = athena_client.start_query_execution(
        QueryString=params["create_table_query"],
        QueryExecutionContext={
            'Database': params['database']
        },
        ResultConfiguration={
            'OutputLocation': 's3://' + params['bucket'] + '/create_table_query/'
        },
        WorkGroup='shooting_insights'
    )

    return {
        'statusCode': 200,
        'body': 'hi'
    }    