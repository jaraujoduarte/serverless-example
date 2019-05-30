import decimal
import json
import logging
import uuid

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            return str(o)
        return super(DecimalEncoder, self).default(o)

def list_movies(**kwargs):
    table = dynamodb.Table('movie')
    items = json.dumps(table.scan()['Items'], cls=DecimalEncoder)
    return 200, items

def submit_rating(**kwargs):
    ratings = json.loads(kwargs['body'])['ratings']
    logger.info(ratings)
    table = dynamodb.Table('rating')

    for k, v in ratings.items():
        table.put_item(
            Item={
                'id': str(uuid.uuid1()),
                'move_id': k,
                'value': v
            }
        )
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
    logger.info("Executing api lambda handler")
    calling_function = None
    response_code = 200
    response_body = None

    try:
        calling_function = function_map[event['httpMethod']][event['path']]
    except KeyError:
        response_code, response_body = (400, f"{event['httpMethod']} {event['path']} not found")
        logger.error(response_body)

    try:
        if calling_function:
            query_params = event.get('queryStringParameters', {})
            response_code, response_body = calling_function(params=query_params, body=event['body'])
    except Exception as e:
        logger.exception(e)
        response_code, response_body = 500, e

    response = {
        "statusCode": response_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
        },
        "body": str(response_body)
    }

    return response
