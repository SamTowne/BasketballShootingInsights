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
    
    shots_attempted = 110
    shots_made = 0
    
    # for num in range(10):
    #     shots_made += body["shots_made_spot_"+str(num+1)] 
    
    print(shots_made)
    shots_made_spot_1 = body["shots_made_spot_1"]
    shots_made_spot_2 = body["shots_made_spot_2"]
    shots_made_spot_3 = body["shots_made_spot_3"]
    # shots_made_spot_4 = response[3].getResponse();
    # shots_made_spot_5 = response[4].getResponse();
    # shots_made_spot_6 = response[5].getResponse();
    # shots_made_spot_7 = response[6].getResponse();
    # shots_made_spot_8 = 
    # shots_made_spot_9 = 
    # shots_made_spot_10 = 
    # shots_made_spot_11 =
    
    shots_made = shots_made_spot_1 + shots_made_spot_2 + shots_made_spot_3
    
    return {
        'statusCode': 200,
        'body': json.dumps(body)
    }