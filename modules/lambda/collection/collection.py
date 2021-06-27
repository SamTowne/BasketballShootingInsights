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
    
    file_name = str(uuid.uuid4()) + ".json"
    
    s3_path = "collection/3point/" + file_name
    
    s3 = boto3.resource("s3")
    
    s3.Bucket(bucket_name).put_object(Key=s3_path, Body=json.dumps(body), ContentType="application/json", )

    payload = json.dumps({'bucket': "{_bucket}".format(_bucket=bucket_name),'path': "{_path}".format(_path=s3_path)})

    ### Invoke processing lambda (async)

    lambda_client = boto3.client("lambda")
    lambda_client.invoke(FunctionName='processing',
                     InvocationType='Event',
                     LogType='None',
                     Payload= payload
                     )
    
    return {
        'statusCode': 200,
        'body': 'hi'
    }