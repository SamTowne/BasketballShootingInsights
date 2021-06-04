import json
import boto3
import urllib.parse
from botocore.exceptions import ClientError

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
    
    #simple email service
    # This address must be verified with Amazon SES.
    SENDER = "Sender Name <chmod777recursively@gmail.com>"
    
    # Replace recipient@example.com with a "To" address. If your account 
    # is still in the sandbox, this address must be verified.
    RECIPIENT = "chmod777recursively@gmail.com"
    
    # If necessary, replace us-west-2 with the AWS Region you're using for Amazon SES.
    AWS_REGION = "us-east-1"
    
    # The subject line for the email.
    SUBJECT = "Shooting Drill Results"
    
    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = ("Amazon SES Test (Python)\r\n"
                 "This email was sent with Amazon SES using the "
                 "AWS SDK for Python (Boto)."
                )
                
    # The HTML body of the email.
    BODY_HTML = """<html>
    <head></head>
    <body>
      <h1>Amazon SES Test (SDK for Python)</h1>
      <p>This email was sent with
        <a href='https://aws.amazon.com/ses/'>Amazon SES</a> using the
        <a href='https://aws.amazon.com/sdk-for-python/'>
          AWS SDK for Python (Boto)</a>.</p>
    </body>
    </html>
                """            
    
    # The character encoding for the email.
    CHARSET = "UTF-8"
    
    # Create a new SES resource and specify a region.
    client = boto3.client('ses',region_name=AWS_REGION)
    
    # Try to send the email.
    try:
        #Provide the contents of the email.
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
        )
    # Display an error if something goes wrong.	
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])    
        
    return {
        'statusCode': 200,
        'body': json.dumps(body)
    }