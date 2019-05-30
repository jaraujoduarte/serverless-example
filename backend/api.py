import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

def list_movies():
    return 200, {}

def submit_rating(ratings):
    return 200, "Rating submitted"

function_map = {
    'GET': {
        '/movie': list_movies
    },
    'POST': {
        '/rating': submit_rating
    }
}

def lambda_handler(event, context):
    logger.info("Executing lambda handler")
    calling_function = None

    try:
        calling_function = function_map[event['httpMethod']][event['path']]
    except KeyError:
        response_code, response_body = (400, f"{event['httpMethod']} {event['path']} not found")
        logger.error(response_body)

    try:
        if calling_function:
            response_code, response_body = calling_function(body=event['body'],
                                                **event['queryStringParameters'])
    except Exception as e:
        logger.exception(e)
        response_code, response_body = 500, e

    response = {
        "statusCode": response_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
        },
        "body": response_body
    }

    return response
