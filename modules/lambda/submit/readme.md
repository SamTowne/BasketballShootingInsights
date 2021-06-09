## Submit

submit.py is the target of post requests to the Shooting Insights API Gateway. It is triggered each time a successful post is made to the API Gateway `/si/submit` route. It stores the HTTP Post data as a json object within the data bucket. The file is given a random name and .json extension.