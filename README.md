# ShootingInsights

Serverless project to email basketball stats from a shooting drill.

### App Flow

Google Form Submit => Google Trigger => Google Apps Script HTTP POST (node.js) => Amazon API Gateway => AWS Lambda (python)

The python function stores the raw json to an s3 bucket for further processing. Then, it calculates some stats and emails those to me.

### Considerations

What other stats / variables may be useful for modeling in the future?
  - It is hot in Arizona. I wonder if there is a relationship between temp and % made.
  - Total time doing the drill.
  - Heart rate? Could that be pulled in..?
  - Time of day

### List of resources that are not managed via Terraform.

- aws api gateway (must output the endpoint)
- aws simple email service
- google form creation (must output the endpoint)
- google form trigger
- google apps script creation
