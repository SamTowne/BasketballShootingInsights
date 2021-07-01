import json
import boto3
import urllib.parse
import uuid
from botocore.exceptions import ClientError

### Handles post requests to API Gateway, stores data as json object in s3

def lambda_handler(event, context):

    api_route = event['path']

    ### Loads json, sets a unique name (uuid4), and dumps the file into an s3 bucket ###
    
    body = json.loads("{}".format(event['body']))

    bucket_name = "shooting-insights-data"
    temp_bucket_name = "shooting-insights-temp"
    
    file_name = str(uuid.uuid4())
    
    s3_path = "collection" + api_route + "/" + file_name + ".json"
    temp_s3_path = "collection_temp/" + api_route + "/" + file_name + ".json"
    
    s3 = boto3.resource("s3")

    # Put json file in shooting insights data bucket collection path 
    s3.Bucket(bucket_name).put_object(Key=s3_path, Body=json.dumps(body), ContentType="application/json", )

    # Put json file containing the json file's name in unique bucket so processing can obtain the correct file
    payload = json.dumps({'file': "{_file}".format(_file=file_name),'api_route': "{_api_route}".format(_api_route=api_route)})
    s3.Bucket(temp_bucket_name).put_object(Key=temp_s3_path, Body= payload, ContentType="application/json", )

    ### Invoke processing lambda (async)
    lambda_client = boto3.client("lambda")
    lambda_client.invoke(FunctionName='setup_processing',
                     InvocationType='Event',
                     LogType='None',
                     Payload=payload
                     )
    
    return {
        'statusCode': 200,
        'body': 'hi'
    }