import json
import boto3

def lambda_handler(event, context):

    ### Retrieve the shooting drill file ###
    s3 = boto3.resource("s3")
    content_object = s3.Object(event['bucket'],event['path'])
    file_content = content_object.get()['Body'].read().decode('utf-8')
    body = json.loads(file_content)
    
    ### Calculate shots made and shooting percentage ###
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

    ### Athena Query

    client = boto3.client('athena')

    params = {
    'region': 'us-east-1',
    'database': 'shooting_insights',
    'bucket': 'shooting-insights-athena-results',
    'total_made_each_spot_query': 
    """
    SELECT
        count(spot_1),
        count(spot_1) * 44,
        sum(spot_1),
        sum(spot_2),
        sum(spot_3),
        sum(spot_4),
        sum(spot_5),
        sum(spot_6),
        sum(spot_7),
        sum(spot_8),
        sum(spot_9),
        sum(spot_10),
        sum(spot_11)
        from shooting_insights;
    """
    }

    total_each_spot_response = client.start_query_execution(
        QueryString=params["total_made_each_spot_query"],
        QueryExecutionContext={
            'Database': params['database']
        },
        ResultConfiguration={
            'OutputLocation': 's3://' + params['bucket'] + '/total_made_each_spot_query/'
        },
        WorkGroup='shooting_insights'
    )
    
    # ### Send an email using Simple Email Service ###
    
    # SENDER = "Sender Name <chmod777recursively@gmail.com>"
    # RECIPIENT = "chmod777recursively@gmail.com"
    # AWS_REGION = "us-east-1"
    # SUBJECT = "3 Point Shooting Drill"

    # # The email body for recipients with non-HTML email clients.
    # BODY_TEXT = "Dear Samuel, You made " + str(shots_made) + "shots out of " + str(shots_attempted) + "." + "\r\n" + "The data from this shooting drill was stored to an AWS S3 Bucket."

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
    
    # # The character encoding for the email.
    # CHARSET = "UTF-8"
    
    # # Create a new SES resource and specify a region.
    # client = boto3.client('ses',region_name=AWS_REGION)
    
    # # Send the email
    # response = client.send_email(
    #     Destination={
    #         'ToAddresses': [
    #             RECIPIENT,
    #         ],
    #     },
    #     Message={
    #         'Body': {
    #             'Html': {
    #                 'Charset': CHARSET,
    #                 'Data': BODY_HTML,
    #             },
    #             'Text': {
    #                 'Charset': CHARSET,
    #                 'Data': BODY_TEXT,
    #             },
    #         },
    #         'Subject': {
    #             'Charset': CHARSET,
    #             'Data': SUBJECT,
    #         },
    #     },
    #     Source=SENDER,
    # )

    return {
        'statusCode': 200,
        'body': 'hi'
    }