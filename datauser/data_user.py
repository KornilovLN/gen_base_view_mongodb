# datauser/data_user.py

import pymongo
import time
import json
from bson import json_util

def fetch_data():
    while True:
        try:
            client = pymongo.MongoClient("mongodb://my_mongo:27017/")
            db = client["mydatabase"]
            collection = db["mycollection"]
            while True:
                for record in collection.find().sort("timestamp"):
                    print(json.dumps(record, indent=4, default=json_util.default))
                time.sleep(3)
        except pymongo.errors.ServerSelectionTimeoutError as err:
            print("Could not connect to MongoDB: ", err)
            time.sleep(5)

if __name__ == "__main__":
    time.sleep(10)  # Wait for MongoDB to be ready
    fetch_data()

'''
def fetch_data():
    client = pymongo.MongoClient("mongodb://mongo_user:27017/")
    db = client["mydatabase"]
    collection = db["mycollection"]
    while True:
        for record in collection.find().sort("timestamp"):
            print(json.dumps(record, indent=4, default=json_util.default))
        time.sleep(3)

if __name__ == "__main__":
    time.sleep(10)  # Wait for MongoDB to be ready
    fetch_data()
'''

'''
import pymongo
import time

def fetch_data():
    client = pymongo.MongoClient("mongodb://mongo_user:27017/")
    db = client["mydatabase"]
    collection = db["mycollection"]
    while True:
        for record in collection.find().sort("timestamp"):
            print(record)
        time.sleep(3)

if __name__ == "__main__":
    time.sleep(10)  # Wait for MongoDB to be ready
    fetch_data()
'''
