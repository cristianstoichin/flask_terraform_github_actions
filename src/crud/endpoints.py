import awsgi
import json
from flask import (
    Flask,
    Response,
    request
)
import os
import time
from boto3.dynamodb.conditions import Key
import boto3
import datetime

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["table_name"])
ProductKey = "Product"

app = Flask(__name__)


@app.route("/products", methods=["GET"])
def get_items():
    # Code to get items from database or elsewhere
    return json.dumps({"result": True, "message": "Not Implemented"})


@app.route("/product", methods=["POST"])
def create_item():
    content = request.get_json(silent=True)
    
    response = table.query(
        KeyConditionExpression=Key("PK").eq(ProductKey) & Key("RK").eq(content['productKey'])
    )

    records = response["Items"]

    if records is not None and len(records) > 0:
        return Response(
            response=json.dumps({"result": False}),
            status=409,
            headers={
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Credentials": False,
                "Content-Type": "application/json",
            },
        )

    timestamp = int(time.time())

    params = {
        "Item": {
            "PK": ProductKey,
            "RK": content['productKey'],
            "productName": content['productName'],
            "productDescription": content['productDescription'],
            "expiration": add_days(1),
            "createdAt": timestamp,
            "updatedAt": timestamp,
        }
    }

    table.put_item(Item=params["Item"])

    return Response(
        response=json.dumps({"result": True}),
        status=201,
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": False,
            "Content-Type": "application/json",
        },
    )


@app.route("/product", methods=["PUT"])
def update_item():
    content = request.get_json(silent=True)
    
    response = table.query(
        KeyConditionExpression=Key("PK").eq(ProductKey) & Key("RK").eq(content['productKey'])
    )

    records = response["Items"]

    if records is None or len(records) == 0:
        return Response(
            response=json.dumps({"result": False}),
            status=404,
            headers={
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Credentials": False,
                "Content-Type": "application/json",
            },
        )

    item = records[0]

    timestamp = int(time.time())

    params = {
        "Item": {
            "PK": ProductKey,
            "RK": content['productKey'],
            "productName": content['productName'],
            "productDescription": content['productDescription'],
            "expiration": item["expiration"],
            "createdAt": item["createdAt"],
            "updatedAt": timestamp,
        }
    }

    table.put_item(Item=params["Item"])
     
    return Response(
        response=json.dumps({"result": True}),
        status=200,
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": False,
            "Content-Type": "application/json",
        },
    )


@app.route("/product/<productKey>", methods=["GET"])
def get_item(productKey: str):
    # Code to retrieve item with given ID from database or elsewhere
    response = table.query(
        KeyConditionExpression=Key("PK").eq(ProductKey) & Key("RK").eq(productKey)
    )

    records = response["Items"]

    if records is None or len(records) == 0:
        return Response(
            response=json.dumps({"result": False}),
            status=404,
            headers={
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Credentials": False,
                "Content-Type": "application/json",
            },
        )

    record = records[0]
    print(record)
    response = {}
    response["productKey"] = record["RK"]
    response["productName"] = record["productName"]
    response["productDescription"] = record["productDescription"]

    return Response(
        response=json.dumps(response),
        status=200,
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": False,
            "Content-Type": "application/json",
        },
    )


@app.route("/product/<id>", methods=["DELETE"])
def delete_item(id):
    # Code to delete item with given ID from database or elsewhere
    return json.dumps({"success": True})


def lambda_handler(event, context):
    return awsgi.response(app, event, context)


def add_days(extra_days: int) -> int:
    today = datetime.date.today()
    added_days = datetime.timedelta(days=extra_days)
    result = today + added_days
    return int(result.strftime("%s"))
