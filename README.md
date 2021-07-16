# Basketball Drill Bot :basketball:

Basketball Drill Bot measures basketball shooting drill results over time.

## App Strategy :building_construction:
- Event-driven and decoupled
- Serverless data processing
- Low cost per handled event

## Tech Toolbox :toolbox:
- Terraform
- API Gateway, Lambda, DyanmoDB, S3, Athena, Glue, Simple Email Service, IAM
- Hashicorp Configuration Language, Python, Node.js
- Google Forms

## Application Flow

Submit :arrow_right: Collect :arrow_right: Pre-Process :arrow_right: Process :arrow_right: Respond :arrow_right: Clean

1. The user submits a Google Form with the results from a shooting drill.
2. The form submit event invokes an OnSubmit node.js handler which sends the results over to an AWS API Gateway endpoint.
3. The API Gateway invokes collection.py Lambda and hands off the event data.
4. collection.py stores the data to an S3 bucket, creates a temp file for this event, and invokes Lambda setup_processing.py.
5. setup_processing.py starts execution of an Athena Query to create a database and glue table for this event.
6. The completion of the query creates a bucket notification. The bucket notification invokes processing.py Lambda.
7. processing.py starts execution of an Athena Query to obtain historical data for this user. This includes data from previous submissions of the same type of shooting drill.
8. The completion of the query creates a bucket notification. The bucket notification invokes response.py Lambda.
9. response.py formats the athena results into an email, sends it, and invokes the cleanup.py Lambda.
10. cleanup.py runs to remove temp files.

The response email provides drill stats.

![email example](img/email_example.png)


## Terraform Modules
 - **Bootstrap** creates the foundational cloud resources.
 - **Collection** feeds data into the app. The entry point is a Google form. The user inputs the results of their shooting drill. This includes the shots made from each location and the current temperature. Submission of the form kicks off a serverless app flow to store the data in AWS S3 for further processing.
 - **Processing** draws insight from the data. The collection step results in raw json objects stored in s3. Each POST to the api gateway results in an individual json object being stored. Processing runs queries against these json files. When complete, it triggers the response step.
 - **Response** emails the results to the user.
 - **Cleanup** deletes temporary files created during runtime.

## Functionality
Basketball Drill Bot currently supports three point and mid range shooting drill submissions. Each drill involves attempting 4 shots from each of 11 locations. Each drill correlates to an API route such as 

https://AWS-Generated-ID.execute-api.AWS-Region.amazonaws.com/threepoint

or 

https://AWS-Generated-ID.execute-api.AWS-Region.amazonaws.com/midrange


### Three Point

![three point shooting locations](img/three_point.png)

### Mid Range

![mid range shooting locations](img/mid_range.png)
