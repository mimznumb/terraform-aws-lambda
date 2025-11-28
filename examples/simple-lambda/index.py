def handler(event, context):
    """
    Simple Lambda handler that returns a greeting.
    """
    import os
    import json
    
    greeting = os.environ.get('GREETING', 'Hello')
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': greeting,
            'event': event
        })
    }
