from awsgi import awsgi
import json
from flask import Flask
import os
import time
from boto3.dynamodb.conditions import Key
import boto3
import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['table_name'])
ProductKey='Product'

app = Flask(__name__)

@app.route('/products', methods=['GET'])
def get_items():
    # Code to get items from database or elsewhere
    return json.dumps({'success': True})

@app.route('/product', methods=['POST'])
def create_item(productName: str, productKey: str, productDescription: str):
    response = table.query(
        KeyConditionExpression=Key('PK').eq(ProductKey) & Key('RK').eq(productKey)
    )
    
    records = response['Items']
    
    if records is not None and len(records) > 0:
        return {
            'statusCode': 409,
            'headers': {
                'Access-Control-Allow-Origin': '*', 
                'Access-Control-Allow-Credentials': False,
            },
            'body': json.dumps({
                'result': False
            })
        }
    
    timestamp = int(time.time())

    params = {
        'Item': {
            'PK': ProductKey,
            'RK': productKey,
            'productName': productName,
            'productDescription': productDescription,
            'expiration': add_days(1),
            'createdAt': timestamp,
            'updatedAt': timestamp
        }
    }

    table.put_item(Item=params['Item'])
    
    return {
        'statusCode': 201,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Credentials': False,
        },
        'body': json.dumps({'response': True })
    }

@app.route('/product', methods=['PUT'])
def update_item(productName: str, productKey: str, productDescription: str):
    # Code to create item in database or elsewhere
    response = table.query(
        KeyConditionExpression=Key('PK').eq(ProductKey) & Key('RK').eq(productKey)
    )
    
    records = response['Items']
    
    if records is None or len(records) == 0:
        return {
            'statusCode': 404,
            'headers': {
                'Access-Control-Allow-Origin': '*', 
                'Access-Control-Allow-Credentials': False,
            },
            'body': json.dumps({
                'result': False
            })
        }
    
    item = records[0]
   
    timestamp = int(time.time())
    
    params = {
        'Item': {
            'PK': ProductKey,
            'RK': productKey,
            'productName': productName,
            'productDescription': productDescription,
            'expiration': item['expiration'],
            'createdAt': item['createdAt'],
            'updatedAt': timestamp
        }
    }

    table.put_item(Item=params['Item'])
    
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Credentials': False,
        },
        'body': json.dumps({'result': True})
    }

@app.route('/items/<id>', methods=['DELETE'])
def delete_item(id):
    # Code to delete item with given ID from database or elsewhere
    return json.dumps({'success': True})

def lambda_handler(event, context):
    return awsgi.response(app, event, context)

def add_days(extra_days: int) -> int:
    today = datetime.date.today()
    added_days = datetime.timedelta(days=extra_days)
    result = today + added_days
    return int(result.strftime('%s'))