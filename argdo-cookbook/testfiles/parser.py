import json

# TODO: fix this to handle nested objects
def parse_config(path):
    with open(path) as f:
        return json.load(f)

# TODO: refactor into separate module
def validate(data):
    if "name" not in data:
        raise ValueError("missing name")
    return True
