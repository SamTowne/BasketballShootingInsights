import json
import boto3
import urllib.parse
import uuid
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    
    ### Loads json, sets a unique name (uuid4), and dumps the file into an s3 bucket ###
    
    body = json.loads("{}".format(event['body']))
    
    bucket_name = "shooting-insights-data"
    
    file_name = str(uuid.uuid4()) + ".json"
    
    s3_path = "/test/" + file_name
    
    s3 = boto3.resource("s3")
    
    s3.Bucket(bucket_name).put_object(Key=s3_path, Body=json.dumps(body), ContentType="application/json", )
    
    ### Shots made and shooting percentage ###
    # TODO move this functionality into individual functions.. with try catches
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
    
    shots_attempted = 110
    
    shooting_percentage_long = 100 * float(shots_made)/float(shots_attempted)
    shooting_percentage = round(shooting_percentage_long,3)
    
    ### simple email service ###
    
    # This address must be verified with Amazon SES.
    SENDER = "Sender Name <chmod777recursively@gmail.com>"
    
    # Replace recipient@example.com with a "To" address. If your account 
    # is still in the sandbox, this address must be verified.
    RECIPIENT = "chmod777recursively@gmail.com"
    
    # If necessary, replace us-west-2 with the AWS Region you're using for Amazon SES.
    AWS_REGION = "us-east-1"
    
    # The subject line for the email.
    SUBJECT = "3 Point Shooting Drill"
    
    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = ""# "Dear Samuel," + "\r\n" + "Here are your shooting results:" +"\r\n"+ "Shots Made = " + shots_made + "\r\n" + "Shooting Percentage = " + shooting_percentage
                
    # The HTML body of the email.
    BODY_HTML = """<html>
    <head></head>
    <body>
      <h1>Shooting Insights</h1>
      <br>
      <p>Dear Samuel,</p>
      <br>
      <p>You made <b>{shots} shots</b> out of 110.</p>
      <p>Your shooting percentage was <b>{shot_perc}%</b>.</p>
      <p>The temperature was <b>{temperature}&deg;F</b>.</p>
      <br>
      <p>The data from this shooting drill was stored to an AWS S3 Bucket because why not:</p>
      <p>{json_body}</p>
      <h4>A serverless app by Sam Towne ¯\_(ツ)_/¯</h4>
    </body>
    </html>
                """.format(shots=shots_made,shot_perc=shooting_percentage,temperature=temp,json_body=body)            
    
    # The character encoding for the email.
    CHARSET = "UTF-8"
    
    # Create a new SES resource and specify a region.
    client = boto3.client('ses',region_name=AWS_REGION)
    
    # Try to send the email.
    # try:
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
    )# TODO: why does the error handling cause this to crash?
    # Display an error if something goes wrong.	
    # except ClientError as e:
    #     print(e.response['Error']['Message'])
    # else:
    #     print("Email sent! Message ID:"),
    #     print(response['MessageId'])    
        
    return {
        'statusCode': 200,
        'body': json.dumps(body)
    }