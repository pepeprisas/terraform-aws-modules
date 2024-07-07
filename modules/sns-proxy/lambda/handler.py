from __future__ import print_function

import json
from botocore.vendored import requests
import os

def lambda_handler(event, context):
    NOTIFICATION_ENDPOINT = os.environ['notification_endpoint']
    message_content = json.dumps(event['Records'][0]['Sns'])
    print("Received event: " + message_content)
    response = requests.post(NOTIFICATION_ENDPOINT, json=event['Records'][0]['Sns'])
    message = event['Records'][0]['Sns']['Message']
    print("From SNS: " + message)
    return message