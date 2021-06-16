## Collection Lambda Function

The Collection Lambda Function is the target of post requests to the Shooting Insights API Gateway. It is triggered each time a successful post is made to the API Gateway `/si/submit` route. It stores the HTTP Post data as a json object within the data bucket. The file is given a random name and .json extension. Then, it triggers the Processing Lambda function to further process the data.

TODO:
- move everything but storing of the raw json body out of this function
- consider error handling and response