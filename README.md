# Basketball Drill Bot :basketball:

Basketball Drill Bot measures basketball shooting drill results over time.

## App Strategy :building_construction:
- Event-driven and decoupled
- Serverless data processing
- Low cost per handled event
- Data Visualization with pretty colors

## Tech Toolbox :toolbox:
- Terraform
- API Gateway, Lambda, DyanmoDB, S3, Athena, Glue, Simple Email Service, IAM, Quicksight
- Hashicorp Configuration Language, Python, Node.js
- Google Forms

### 3 Point Shooting Drill Dashboard
<iframe
    width="960"
    height="720"
    src="https://us-east-1.quicksight.aws.amazon.com/sn/embed/share/accounts/272773485930/dashboards/7ff57b68-48d9-44e0-874d-0f335f1b5471?directory_alias=samtowne-dev">
</iframe>

### Midrange Shooting Drill Dashboard
<iframe
    width="960"
    height="720"
    src="https://us-east-1.quicksight.aws.amazon.com/sn/embed/share/accounts/272773485930/dashboards/994bad2e-57b3-45c7-bc21-168516fe5a83?directory_alias=samtowne-dev">
</iframe>

## Application Flow

Submit :arrow_right: Collect :arrow_right: Pre-Process :arrow_right: Process :arrow_right: Respond :arrow_right: Clean

**Submit**
- Google Form submission triggers an HTTP post to an AWS API Gateway. 
- The API Gateway invokes Collect Lambda.

**Collect**
- Collect stores the data to an S3 bucket, creates a temp file for this event, and invokes Pre-Process Lambda.

**Pre-Process**
- Pre-Process executes an Athena Query to create a database and glue table for this event.
- When the query completes, a bucket notification invokes Process Lambda.

**Process**
- Process executes another Athena Query. This is to obtain the data needed to perform average shooting percentage calculations against all previous submissions of this drill type.
- When the query completes, a bucket notification invokes Respond Lambda.

**Respond**
- Respond sends an email with the results and invokes Clean. 

**Clean**
- Clean runs to remove temp files.

The response email provides drill stats.

![email example](img/email_example.png)

**Presentation**
- The data is ingested to Amazon Quicksight to provide dashboard summary views.

## Terraform Modules
 - **Bootstrap** creates the Terraform state bucket and dynamodb state-locking table.
 - **Collection** feeds data into the application.
 - **Processing** draws insight from the data. The collection step results in raw json objects stored in s3. Each POST to the api gateway results in an individual json object being stored. Processing runs queries against the recent data as well as the historicall (previously submitted) json files.
 - **Response** emails the results to the user.
 - **Cleanup** deletes temporary files created during runtime.
 - **Presentation** configuration for Amazon Quicksight dashboards.

## Functionality
Basketball Drill Bot currently supports three point and mid range shooting drill submissions. Each drill involves attempting 4 shots from each of 11 locations. Each drill correlates to an API route such as 

https://AWS-Generated-ID.execute-api.AWS-Region.amazonaws.com/threepoint

or 

https://AWS-Generated-ID.execute-api.AWS-Region.amazonaws.com/midrange


### Three Point

![three point shooting locations](img/three_point.png)

### Mid Range

![mid range shooting locations](img/mid_range.png)
