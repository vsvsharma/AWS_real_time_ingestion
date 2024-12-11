import requests
import datetime
import boto3
import json

firehose= boto3.client('firehose', region_name='ap-south-1')

class RandomUser:

    """
    decalring the url for the API from which is being fetched and
    making it available throughout the class
    """
    
    def __init__(self,url="https://randomuser.me/api/?format=json"):
        self.url=url
        self.data=None

    def fetch_data(self):
        self.data=requests.get(self.url).json()

        """
        1. Removing the postcode from the data
        2. adding the current time as p_time & current date as p_date key in the data 
        """

        if "postcode" in self.data["results"][0]["location"]:
            del self.data["results"][0]["location"]["postcode"]
        
        current_date=datetime.datetime.now().strftime('%Y-%m-%d')
        current_time=datetime.datetime.now().strftime('%H:%M:%S')

        self.data['p_date']=current_date
        self.data['p_time']=current_time

        """
        sending data to the firehose stream
        """

    def send_data_to_firehose(self):
        data_str=json.dumps(self.data)

        reponse=firehose.put_record(
            DeliveryStreamName='user-data-ingestion-stream',
            Record={
                'Data': data_str + '\n' # append a newline character if needed
            }
        )
        print(reponse)

def handler(event,context):
    random_user=RandomUser()
    random_user.fetch_data()
    random_user.send_data_to_firehose()
    