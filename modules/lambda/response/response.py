import boto3
import json

def lambda_handler(event, context):

    ### Retrieve the shooting drill file ###
    s3 = boto3.resource("s3")
    shooting_insights_data_bucket = s3.Bucket('shooting-insights-data')
    processed_temp_file = []
    
    for obj in shooting_insights_data_bucket.objects.filter(Prefix="temp/3point/"):
      processed_temp_file = json.loads(obj.get()['Body'].read().decode('utf-8'))

    shots_made          = str(processed_temp_file['shots_made'])
    shots_attempted     = str(processed_temp_file['shots_attempted'])
    shooting_percentage = str(processed_temp_file['shooting_percentage'])
    temp                = str(processed_temp_file['temp'])

    ### Retrieve the Athena Results
    athena_client = boto3.client('athena')
    total_made_each_spot_query_results = athena_client.get_query_results(QueryExecutionId=processed_temp_file['total_made_each_spot_athena_execution_id'])
    data_list = total_made_each_spot_query_results[1].values
    total_shooting_drills = data_list[0]

    total_made_each_spot = total_shooting_drills 
        
    ### Send an email using Simple Email Service ###

    SENDER = "Sender Name <chmod777recursively@gmail.com>"
    RECIPIENT = "chmod777recursively@gmail.com"
    AWS_REGION = "us-east-1"
    #SUBJECT = "3 Point Shooting Drill"
    SUBJECT = "TEST"


    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = "Dear Samuel, You made " + shots_made + " shots out of " + shots_attempted + "." + "\r\n" + "The data from this shooting drill was stored to an AWS S3 Bucket."
    #BODY_HTML = "test html body " + str(json.loads(processed_temp_file))
    # The HTML body of the email.
    BODY_HTML = """<html>
    <head></head>
    <body>
      <h1>Shooting Insights</h1>
      <br>
      <p>Dear Samuel,</p>
      <br>
      <p>You made <b>{_shots_made} shots</b> out of {_shots_attempted}.</p>
      <p>Your shooting percentage was <b>{_shooting_percentage}%</b>.</p>
      <p>The temperature was <b>{_temp}&deg;F</b>.</p>
      <br>
      <p>Shooting percentages each location, and totals: {_total_made_each_spot}.</p>
      <h4>A serverless app by Sam Towne ¯\_(ツ)_/¯</h4>
    </body>
    </html>
                """.format(_shots_made=shots_made,_shots_attempted=shots_attempted,_shooting_percentage=shooting_percentage,_temp=temp,_total_made_each_spot=total_made_each_spot)            
    
    # The character encoding for the email.
    CHARSET = "UTF-8"
    
    # Create a new SES resource and specify a region.
    ses_client = boto3.client('ses',region_name=AWS_REGION)
    
    # Send the email
    send_email_response = ses_client.send_email(
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

    ### Invoke cleanup lambda (async)

    lambda_client = boto3.client("lambda")
    lambda_client.invoke(FunctionName='cleanup',
                     InvocationType='Event',
                     LogType='None'
                     )

    return {
        'statusCode': 200,
        'body': 'hi'
    }