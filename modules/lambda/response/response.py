import boto3
import json

def lambda_handler(event, context):
    ### Send an email using Simple Email Service ###
    
    SENDER = "Sender Name <chmod777recursively@gmail.com>"
    RECIPIENT = "chmod777recursively@gmail.com"
    AWS_REGION = "us-east-1"
    # SUBJECT = "3 Point Shooting Drill"
    SUBJECT = "TEST"

    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = "Dear Samuel, You made " + "not implemented " + "shots out of " + "not implemented " + "." + "\r\n" + "The data from this shooting drill was stored to an AWS S3 Bucket."
    BODY_HTML = "test html body"
    # # The HTML body of the email.
    # BODY_HTML = """<html>
    # <head></head>
    # <body>
    #   <h1>Shooting Insights</h1>
    #   <br>
    #   <p>Dear Samuel,</p>
    #   <br>
    #   <p>You made <b>{shots} shots</b> out of {attempted}.</p>
    #   <p>Your shooting percentage was <b>{shot_perc}%</b>.</p>
    #   <p>The temperature was <b>{temperature}&deg;F</b>.</p>
    #   <br>
    #   <p>The data from this shooting drill was stored to an AWS S3 Bucket:</p>
    #   <p>{json_body}</p>
    #   <h4>A serverless app by Sam Towne ¯\_(ツ)_/¯</h4>
    # </body>
    # </html>
    #             """.format(shots=shots_made,attempted=shots_attempted,shot_perc=shooting_percentage,temperature=temp,json_body=body)            
    
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
        'body': 'hi'
    }