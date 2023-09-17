import json
import boto3
import uuid
from botocore.exceptions import ClientError
import logging


LOGGER = logging.getLogger()

"""
This is the target for API Gateway post routes.
It archives the event data.
It creates a temp file of this event for downstream services.
It invokes the setup processing lambda function.
"""
def lambda_handler(event, context):

    # Make a unique file name for this event
    file_name = str(uuid.uuid4())
    LOGGER.info('Processing file %s.', file_name)
    # Set the route used
    api_route = event['path']

    # Initialize boto3 s3 client
    s3_resource = boto3.resource("s3")

    # Write event data to <data_bucket>/collection/<api_route>/<uuid4>.json
    s3_resource.Bucket("shooting-insights-data").put_object(Key="collection" + api_route + "/" + file_name + ".json", Body=json.dumps(json.loads("{}".format(event['body']))), ContentType="application/json", )

    # Write temp file to <temp_bucket>/temp.json
    payload = json.dumps({'file': "{_file}".format(_file=file_name),'api_route': "{_api_route}".format(_api_route=api_route)})
    s3_resource.Bucket("shooting-insights-temp").put_object(Key="temp.json", Body= payload, ContentType="application/json", )

    # Invoke setup processing asynchronously
    LOGGER.info('Invoking Setup Processing lambda with payload %s.', payload)
    lambda_client = boto3.client("lambda")
    lambda_client.invoke(FunctionName='setup_processing',
                     InvocationType='Event',
                     LogType='None',
                     Payload=payload
                     )

    return {
        'statusCode': 200,
        'body': 'hi'
    }