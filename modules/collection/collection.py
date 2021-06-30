import json
import boto3
import urllib.parse
import uuid
from botocore.exceptions import ClientError

### Handles post requests to API Gateway, stores data as json object in s3

def lambda_handler(event, context):
    
    ### Loads json, sets a unique name (uuid4), and dumps the file into an s3 bucket ###
    
    body = json.loads("{}".format(event['body']))
    
    bucket_name = "shooting-insights-data"
    temp_bucket_name = "shooting-insights-temp"
    
    file_name = str(uuid.uuid4())
    
    s3_path = "collection/3point/" + file_name + ".json"
    temp_s3_path = "collection_temp/3point/" + file_name + ".json"
    
    s3 = boto3.resource("s3")

    # Put json file in shooting insights data bucket collection path 
    s3.Bucket(bucket_name).put_object(Key=s3_path, Body=json.dumps(body), ContentType="application/json", )

    # Put json file containing the json file's name in unique bucket so processing can obtain the correct file
    s3.Bucket(temp_bucket_name).put_object(Key=temp_s3_path, Body=json.dumps({'file': "{_file}".format(_file=file_name)}), ContentType="application/json", )

    ### Invoke processing lambda (async)
    lambda_client = boto3.client("lambda")
    lambda_client.invoke(FunctionName='setup_processing',
                     InvocationType='Event',
                     LogType='None'
                     )
    
    return {
        'statusCode': 200,
        'body': 'hi'
    }