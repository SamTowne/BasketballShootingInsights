import json
import boto3

def lambda_handler(event, context):
    
    s3 = boto3.resource("s3")

    ### Retrieve the shooting drill file name ###
    shooting_insights_temp_bucket = s3.Bucket('shooting-insights-temp')
    json_file_prefix = []
    
    for obj in shooting_insights_temp_bucket.objects.filter(Prefix="collection_temp/3point/"):
      json_file_prefix = json.loads(obj.get()['Body'].read().decode('utf-8'))

    file_prefix = json_file_prefix['file']    

    ### Retrieve the shooting drill file ###
    content_object = s3.Object('shooting-insights-data',"collection/3point/" + file_prefix + ".json")
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

    client = boto3.client('athena')

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
        from shooting_insights;
    """
    }

    total_each_spot_response = client.start_query_execution(
        QueryString=params["total_made_each_spot_query"],
        QueryExecutionContext={
            'Database': params['database']
        },
        ResultConfiguration={
            'OutputLocation': 's3://' + params['bucket'] + '/total_made_each_spot_query/'
        },
        WorkGroup='shooting_insights'
    )

    # Create new json file with Athena execution IDs, shots made, shots attempted, shooting percentage, and the temperature 
    processed_file_content = json.dumps({'total_made_each_spot_athena_execution_id': total_each_spot_response['QueryExecutionId'],'shots_made': shots_made,'shots_attempted': shots_attempted,'shooting_percentage': shooting_percentage, 'temp': temp})
    s3.Object('shooting-insights-data', 'processed/3point/' + file_prefix + ".json" ).put(Body=processed_file_content,ContentType="application/json")

    # Make a temp copy
    s3.Object('shooting-insights-temp', 'processed_temp/3point/' + file_prefix + ".json").copy_from(CopySource='shooting-insights-data/processed/3point/' + file_prefix + ".json")
    

    return {
        'statusCode': 200,
        'body': 'hi'
    }