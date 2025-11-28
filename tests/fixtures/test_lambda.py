import json

def handler(event, context):
    """
    Test Lambda function that returns event data and environment info.
    Used for integration testing.
    """
    import os
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Test Lambda executed successfully',
            'event': event,
            'environment': {
                'TEST_VAR': os.environ.get('TEST_VAR', 'default'),
                'FUNCTION_NAME': context.function_name if context else 'unknown'
            }
        })
    }
