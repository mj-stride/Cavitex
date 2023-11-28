import requests
import json
import time
from datetime import datetime
import os

# url of the json file
url_to_dl = 'https://www.waze.com/row-partnerhub-api/partners/11262491165/waze-feeds/8d2cefb6-9636-402c-adb1-be2977117f2d?format=1'

dl_directory = 'D:/Codes/cavitex/waze/waze_feeds/downloaded_waze/'

def check_folder():
  date_now = datetime.now().strftime('%Y-%m-%d')
  # folder_path = f'{dl_directory}{date_now}'
  folder_path = '{}{}'.format(dl_directory, date_now)
  print(folder_path)
  
  if os.path.isdir(folder_path):
    print('true')
    return folder_path
  else:
    print('false')
    os.makedirs(folder_path)
    return folder_path

def download_json(url):
  try:
    # make a get request to the URL
    response = requests.get(url)
    
    # check if the request is successful
    if response.status_code == 200:
      # parse json content
      json_data = response.json()
      
      # time for file name
      save_path = check_folder()
      
      file_time = datetime.now().strftime('%H%M')
      
      # file name with time
      # file_name = f'{file_time}.json'
      # file_path = f'{save_path}/{file_name}'
      file_name = '{}.json'.format(file_time)
      file_path = '{}/{}'.format(save_path, file_name)
      
      # save the json data to the file
      with open(file_path, 'w') as json_file:
        json.dump(json_data, json_file, indent=4)
                
      # print(f'JSON downloaded successfully and saved to {file_path}')
      print('JSON downloaded successfully and saved to {}'.format(file_path))
    else:
      print('Failed to download JSON. Status Code: {response.status_code}')
  except Exception as e:
    print('An error occurred: {e}')

# run the loop indefinitely
while True:
  download_json(url_to_dl)
    
  time.sleep(120)
