import json
import boto3

def lambda_handler(event, context):

    # collection lambda event body contains the bucket and path to file
    bucket = event['bucket']
    path = event['path']

    #TODO: retrieve the file and confirm that this works
    body = json.loads("{}".format(event['body']))
    
    ### Shots made and shooting percentage ###
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
    
    ### simple email service ###
    
    SENDER = "Sender Name <chmod777recursively@gmail.com>"
    RECIPIENT = "chmod777recursively@gmail.com"
    AWS_REGION = "us-east-1"
    SUBJECT = "3 Point Shooting Drill"

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = "Dear Samuel, You made " + shots_made + "shots out of " + shots_attempted + "." + "\r\n" + "The data from this shooting drill was stored to an AWS S3 Bucket:" + "\r\n" + body

    # The HTML body of the email.
    BODY_HTML = """<html>
    <head></head>
    <body>
      <h1>Shooting Insights</h1>
      <br>
      <p>Dear Samuel,</p>
      <br>
      <p>You made <b>{shots} shots</b> out of {attempted}.</p>
      <p>Your shooting percentage was <b>{shot_perc}%</b>.</p>
      <p>The temperature was <b>{temperature}&deg;F</b>.</p>
      <br>
      <p>The data from this shooting drill was stored to an AWS S3 Bucket:</p>
      <p>{json_body}</p>
      <h4>A serverless app by Sam Towne ¯\_(ツ)_/¯</h4>
    </body>
    </html>
                """.format(shots=shots_made,attempted=shots_attempted,shot_perc=shooting_percentage,temperature=temp,json_body=body)            
    
    # The character encoding for the email.
    CHARSET = "UTF-8"
    
    # Create a new SES resource and specify a region.
    client = boto3.client('ses',region_name=AWS_REGION)
    
    # Send the email
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

    return {
        'statusCode': 200,
        'body': json.dumps(body)
    }