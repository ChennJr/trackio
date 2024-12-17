from PySide6.QtCore import QObject, Slot
from model import Database, SpotifyClient, ContentBasedFilter
import re
from dotenv import load_dotenv
import os
import pandas as pd

class Presenter(QObject):
    def __init__(self, view):
        super().__init__()
        load_dotenv(r"keys.env")
        SPOTIFY_CLIENT_SECRET = os.getenv('SPOTIFY_CLIENT_SECRET')
        SPOTIFY_CLIENT_ID = os.getenv('SPOTIFY_CLIENT_ID')
        self.view = view
        self.user_db = Database()
        self.spotify_client = SpotifyClient(client_id=SPOTIFY_CLIENT_ID, client_secret=SPOTIFY_CLIENT_SECRET)
        self.cbf = ContentBasedFilter()
        self.full_dataset = pd.read_csv(r"full_dataset.csv", engine="pyarrow")
        self.email = ""
        self.user_id = ""

    
    def on_login_clicked(self, email, password):
        if email and password:
            if self.user_db.verify_user(email, password):
                self.email = email
                self.user_id = self.user_db.get_user_id(email)

                opinions = self.user_db.get_opinions(self.user_id)
                if not opinions:
                    track_details_list = self.fetch_track_details()
                    random_track = track_details_list[0]
                    return True, random_track, track_details_list
                
                else:
                    track_details_list = self.fetch_track_details()
                    random_track = track_details_list[0]
                        
                    return True, random_track, track_details_list
            
            else:
                self.view.message = ("Invalid credentials")
                self.view.showMessage.emit()
                return False, [], []
        
        else:
            self.view.message = ("Please enter an email and password")
            self.view.showMessage.emit()
            return False, [], []

    def on_register_submit(self, email, first_name, last_name, password):
        if email and first_name and last_name and password:
            self.save_to_database(email, first_name, last_name, password)
        else:
            self.view.message = ("All fields are required")
            self.view.showMessage.emit()

    def save_to_database(self, email, first_name, last_name, password):
        self.user_db.insert_user(email, first_name, last_name, password)
    
    def email_exists(self, email):
        if self.user_db.email_exists(email):
            self.view.message = ("Account with this email already exists")
            self.view.showMessage.emit()
            return True
        
        return False
    
    def validate_email(self, email):
        pattern = r'^[^@]+@brookeweston\.org$'
        if re.match(pattern, email) is not None:
            return True
        
        else:
            self.view.message = ("Invalid email")
            self.view.showMessage.emit()
            return False
        
    

    def validate_password(self, password):
        if len(password) > 16:
            self.view.message = ("Password needs to be less than 16 characters" )
            self.view.showMessage.emit()
            return False
        
        if len(password) == 0:
            self.view.message = ("Password cannot be empty" )
            self.view.showMessage.emit()
            return False
        
        if not re.search(r'[A-Z]', password):
            self.view.message = ("Password needs to contain an uppercase character" )
            self.view.showMessage.emit()
            return False
        
        if not re.search(r'[a-z]', password):
            self.view.message = ("Password needs to contain a lowercase character" )
            self.view.showMessage.emit()
            return False
        
        if not re.search(r'[0-9]', password):
            self.view.message = ("Password needs to contain a number" )
            self.view.showMessage.emit()
            return False
        
        if not re.search(r'[^A-Za-z0-9()]', password):
            self.view.message = ("Password needs to contain a special character" )
            self.view.showMessage.emit()
            return False
        
        return True
        
    def fetch_track_details(self):

        track_uris = self.user_db.get_user_track_uris(self.user_id)
        if not track_uris:
            track_uris = self.full_dataset.sample(n=1)["track_uri"].values.tolist()
            track_details_list = self.spotify_client.get_track_details(track_uris)

        else:
            track_uris_with_opinons = self.user_db.get_user_track_uris_with_opinions(self.user_id)
            print(track_uris_with_opinons)

            indices, distances = self.cbf.get_similarities(track_uris_with_opinons)
            track_uris = self.full_dataset["track_uri"][indices].tolist()
            
            track_details_list = []
            track_details = self.spotify_client.get_track_details(track_uris)
            track_details_list.extend(track_details)
        
        return track_details_list
    
        
    
    def get_opinions(self, track_uri):
        opinions = self.user_db.get_opinions(self.user_id)
        for opinion in opinions if opinions else []:
            if opinion[0] == track_uri:
                return opinion[1]
        return -1  # Return None if no opinion is found
    
    def save_opinion(self, track_uri, opinion):

        if self.get_opinions(track_uri) is not None and opinion == -1:
            self.user_db.delete_opinion(self.user_id, track_uri)
            
        elif self.get_opinions(track_uri) is None and opinion == -1:
            pass
            
        else:
            self.user_db.save_opinions(self.user_id, track_uri, opinion)
            

    

        

        
    
    
    
    

