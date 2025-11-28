import json

def handler(event, context):
    """
    Simple test Lambda function.
    """
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Lambda executed successfully!',
            'event': event
        })
    }
