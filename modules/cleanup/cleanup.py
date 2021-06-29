import boto3

def lambda_handler(event, context):
    s3 = boto3.resource('s3')
    my_bucket = 'shooting-insights-data'
    for item in my_bucket.objects.filter(Prefix='temp/3point/'):
        item.delete()

    return {
        'statusCode': 200,
        'body': 'hi'
    }