# Shooting Insights

I made Shooting Insights to practice serverless app dev skills. The goal is to design and build a  serverless app that is functional and fun for me to use. I've always enjoyed basketball and decided to make something that is basketball-focused. Shooting Insights allows me to measure my basketball shooting drill results over time.

## Tech Used
- Terraform
- AWS Services: API Gateway, Lambda (boto3), s3, Athena, Glue, Simple Email Service, IAM
- Languages: Hashicorp Configuration Language (HCL), Python, Node.js
- Google Forms

## Application Flow
1. The user submits the Google Form containing the results from the shooting drill.
2. The form submit event triggers a Google Apps Script that makes an HTTP post to the API Gateway.
3. The API Gateway receives the HTTP post and triggers the collection Lambda Function.
4. The collection Lambda Function stores the post data and triggers the setup_processing Lambda Function.
5. The setup_processing Lambda Function starts execution of an Athena Query.
6. The Athena Query results file creation invokes the processing Lambda Function (via bucket notification).
7. The processing Lambda Function starts execution of an Athena Query.
8. The Athena Query results file creation invokes the response Lambda Function (via bucket notification).
9. The response Lambda Function formats the data into an email, sends it, and invokes the cleanup Lambda Function.
10. The cleanup Lambda Function runs to remove temp files.

## Terraform Modules
 - **Bootstrap** builds the app. It creates the foundational cloud resources and tells them to play nicely with one another. Terraform is the primary tool used for this.
 - **Collection** feeds data into the app. The entry point is a Google form. The user inputs the results of their shooting drill. This includes the shots made from each location and the current temperature. Submission of the form kicks off a serverless app flow to store the data in AWS S3 for further processing.
 - **Processing** draws insight from the data. The collection step results in raw json objects stored in s3. Each POST to the api gateway results in an individual json object being stored. Processing runs queries against these json files. When complete, it triggers the response step.
 - **Response** emails the results to the user.
 - **Cleanup** deletes temporary files created during runtime.

## Functionality and Modularity
Shooting Insights currently supports 3 point shooting drill submissions. The drill involves attempting 4 shots from each of 11 locations behind the arc. I plan to modularize the AWS backend so that it can support multiple types of drill submissions such as a mid-range drill or jump-shot drill.

![half court shooting locations](img/3point.png)

The result of a submission is an email.

![email example](img/email_example.png)
