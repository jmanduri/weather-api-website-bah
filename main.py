import json
import os
import logging
from botocore.vendored import requests
import requests

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def weatherfunc(city_zip):

    api_key = '8d2f5bb86d52ea03b736f8c2db5576e1'
    base_url = 'http://api.openweathermap.org/data/2.5/weather?'
    finalurl = base_url + 'zip=' + city_zip + ',us&appid=' + api_key

    response = requests.get(finalurl)
    x = response.json()
    y = x['main']
    city_name = x['name']
    current_temperature = y['temp']
    min_temp = y['temp_min']
    max_temp = y['temp_max']

    return {
        'current_weather': current_temperature,
        'min_temp': min_temp,
        'max_temp': max_temp,
        'weather_state_name': city_name
        }

def lambda_handler(event, context):
    payload = json.loads(event.get('body'))
    city = payload['city_zip']
    return {
        "statusCode": 200,
        "body": json.dumps(weatherfunc(city)),
        "headers":{ 'Access-Control-Allow-Origin' : '*' }
        }