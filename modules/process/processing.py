import json
import boto3

"""
TODO: Cleanup this function
"""
def lambda_handler(event, context):
    

    ### Retrieve the temp file data ###
    s3_client = boto3.client("s3")
    temp_json = json.loads(s3_client.get_object(Bucket='shooting-insights-temp',Key='temp.json')['Body'].read().decode('utf-8'))
    file_prefix = temp_json['file']
    api_route = temp_json['api_route']
    table_name = api_route.replace("/","")

    ### Determine full drill name ###
    drill = "undetermined"
    
    if table_name == 'midrange':
        drill = "Mid Range"
    
    if table_name == 'threepoint':
        drill = "Three Point"
    
    if table_name == 'devgru':
        drill = "DevGru"

    ### Retrieve the shooting drill file ###
    s3_resource = boto3.resource("s3")
    content_object = s3_resource.Object('shooting-insights-data',"collection" + api_route + "/" + file_prefix + ".json")
    file_content = content_object.get()['Body'].read().decode('utf-8')
    body = json.loads(file_content)
    
    ### Calculate shots made and shooting percentage ###
    spot_1 = body["spot_1"]
    spot_2 = body["spot_2"]
    spot_3 = body["spot_3"]
    spot_4 = body["spot_4"]
    spot_5 = body["spot_5"]
    spot_6 = body["spot_6"]
    spot_7 = body["spot_7"]
    spot_8 = body["spot_8"]
    spot_9 = body["spot_9"]
    spot_10 = body["spot_10"]
    spot_11 = body["spot_11"]
    temp = body["temp"]
    
    shots_made = int(spot_1) + int(spot_2) + int(spot_3) + int(spot_4) + int(spot_5) + int(spot_6) + int(spot_7) + int(spot_8) + int(spot_9) + int(spot_10) + int(spot_11)
    
    shots_attempted = 44
    
    shooting_percentage_long = 100 * float(shots_made)/float(shots_attempted)
    shooting_percentage = round(shooting_percentage_long,2)

    ### Athena Query

    athena_client = boto3.client('athena')

    params = {
    'region': 'us-east-1',
    'database': 'shooting_insights',
    'bucket': 'shooting-insights-athena-results',
    'total_made_each_spot_query': 
    """
    SELECT
        count(spot_1),
        count(spot_1) * 44,
        sum(spot_1),
        sum(spot_2),
        sum(spot_3),
        sum(spot_4),
        sum(spot_5),
        sum(spot_6),
        sum(spot_7),
        sum(spot_8),
        sum(spot_9),
        sum(spot_10),
        sum(spot_11)
        from "{_table_name}";
    """.format(_table_name=table_name)
    }

    total_each_spot_response = athena_client.start_query_execution(
        QueryString=params["total_made_each_spot_query"],
        QueryExecutionContext={
            'Database': params['database']
        },
        ResultConfiguration={
            'OutputLocation': 's3://' + params['bucket'] + '/total_made_each_spot_query/'
        },
        WorkGroup='shooting_insights'
    )

    # Create new json file with Athena execution ID, shots made, shots attempted, shooting percentage, temperature, and session uuid
    processed_file_content = json.dumps({'total_made_each_spot_athena_execution_id': total_each_spot_response['QueryExecutionId'],'shots_made': shots_made,'shots_attempted': shots_attempted,'shooting_percentage': shooting_percentage, 'temp': temp,'drill': drill})
    s3_resource.Object('shooting-insights-data', 'processed'+ api_route + "/" + file_prefix + ".json" ).put(Body=processed_file_content,ContentType="application/json")

    # Put temp.json in the temp bucket. This file is read by response Lambda.
    s3_resource.Object('shooting-insights-temp',"temp.json").copy_from(CopySource='shooting-insights-data/processed' + api_route + "/" + file_prefix + ".json")
    

    return {
        'statusCode': 200,
        'body': 'hi'
    }