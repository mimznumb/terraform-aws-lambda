def handler(event, context):
    """
    Lambda handler running in VPC with S3 access.
    """
    import os
    import json
    
    bucket_name = os.environ.get('BUCKET_NAME', 'unknown')
    environment = os.environ.get('ENVIRONMENT', 'dev')
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Lambda running in {environment} environment',
            'bucket': bucket_name,
            'vpc_enabled': True
        })
    }
