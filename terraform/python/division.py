import json

def handler(event, context):
    
    resolve = json.loads(event['body'])
    # Extract input values
    num1 = int(resolve["X"])
    num2 = int(resolve["Y"])
    
    # Perform the operation based on the function
    if num2 == 0:
        result = 0
    else:
        result = num1/num2
    
    # a Python object (dict):
    response = {
        "X": num1,
        "Y": num2,
        "result": result
    }

    return json.dumps(response)
