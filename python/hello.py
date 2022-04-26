"""
   This function will return HTTP status code 200 and simply a 'hello' string.
"""
import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps('hello')
    }
