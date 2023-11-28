import requests
import json
import time

# get location address
def get_address(loc):
  param = {
    'location' : loc
  }

  req = requests.post('http://localhost:8000/location/address', param)

  res = req.json()
  return res
