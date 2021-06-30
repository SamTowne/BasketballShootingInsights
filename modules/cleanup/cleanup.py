import boto3

def lambda_handler(event, context):
    s3 = boto3.resource('s3')

    # Delete everything in the athena results bucket 
    athena_bucket = s3.Bucket('shooting-insights-athena-results')
    athena_bucket.objects.all().delete()

    # Delete everything in the temp bucket
    temp_bucket = s3.Bucket('shooting-insights-temp')
    temp_bucket.objects.all().delete()

    # Delete everything in the processing bucket
    processing_bucket = s3.Bucket('shooting-insights-setup-processing-results')
    processing_bucket.objects.all().delete()

    return {
        'statusCode': 200,
        'body': 'hi'
    }