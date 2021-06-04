import json
import boto3
import urllib.parse

def lambda_handler(event, context):
    
    body = json.loads("{}".format(event['body']))
    
    bucket_name = "shooting-insights-data"
    file_name = "george.txt"
    
    s3_path = "/test/" + file_name
    s3 = boto3.resource("s3")
    
    s3.Bucket(bucket_name).put_object(Key=s3_path, Body=json.dumps(body))

    return {
        'statusCode': 200,
        'body': json.dumps(body)
    }

# JSON is being dumped into static text file (overwritten each time)