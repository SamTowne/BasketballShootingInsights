import json
import boto3

def lambda_handler(event, context):
    bucket_name = "shooting-insights-data"
    file_name = "hello.txt"
    lambda_path = "/tmp/" + file_name
    s3_path = "/directory/" + file_name

    s3 = boto3.resource("s3")
    s3.Bucket(bucket_name).put_object(Key=s3_path, Body=json.dumps(event))

    
    return {
        'statusCode': 200,
        'body': json.dumps(event)
    }
