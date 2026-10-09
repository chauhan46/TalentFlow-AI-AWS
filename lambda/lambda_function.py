import json
import os


def lambda_handler(event, context):
    print("TalentFlow AI Lambda invoked")
    print(json.dumps(event))

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "TalentFlow AI serverless API is working",
            "service": "AWS Lambda",
            "environment": os.environ.get("ENVIRONMENT", "production")
        })
    }
