from PySide6.QtCore import QObject
from model import Database, SpotifyClient, ContentBasedFilter, SpotifyDatasetProcessor, get_file_path
import re
from dotenv import load_dotenv
import os
import glob

class Presenter(QObject):
    def __init__(self, view):
        super().__init__()
        load_dotenv(get_file_path("keys.env"))
        SPOTIFY_CLIENT_SECRET = os.getenv('SPOTIFY_CLIENT_SECRET')
        SPOTIFY_CLIENT_ID = os.getenv('SPOTIFY_CLIENT_ID')
        self.view = view
        self.user_db = Database()
        self.spotify_client = SpotifyClient(client_id=SPOTIFY_CLIENT_ID, client_secret=SPOTIFY_CLIENT_SECRET)
        self.cbf = ContentBasedFilter(client_id=SPOTIFY_CLIENT_ID, client_secret=SPOTIFY_CLIENT_SECRET)
        self.processor = SpotifyDatasetProcessor(client_id=SPOTIFY_CLIENT_ID, client_secret=SPOTIFY_CLIENT_SECRET)
        self.email = ""
        self.user_id = ""

    
    def on_login_clicked(self, email, password):
        if not self.email_exists(email):
            return False, [], []


        if email and password:
            if self.user_db.verify_user(email, password):
                self.email = email
                self.user_id = self.user_db.get_user_id(email)
                self.view.account_type = self.user_db.get_account_type(self.user_id)

                opinions = self.user_db.get_opinions(self.user_id)
                if not opinions:
                    track_details_list = self.fetch_track_details()
                    random_track = track_details_list[0]
                    return True, random_track, track_details_list
                
                else:
                    track_details_list = self.fetch_track_details()
                    track = track_details_list[0]
                        
                    return True, track, track_details_list

            
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
            self.email = email
            self.user_id = self.user_db.get_user_id(email)

            opinions = self.user_db.get_opinions(self.user_id)
            if not opinions:
                track_details_list = self.fetch_track_details()
                random_track = track_details_list[0]
                return True, random_track, track_details_list
                
            else:
                track_details_list = self.fetch_track_details()
                track = track_details_list[0]
                        
                return True, track, track_details_list
        else:
            self.view.message = ("All fields are required")
            self.view.showMessage.emit()
            return False, [], []

    def verify_user_forgotten_password(self, email, first_name, last_name):
        if not self.email_exists(email):
            self.view.message = ("Account does not exist, please register")
            self.view.showMessage.emit()
            return False
        
        elif self.user_db.verify_user_forgotten_password(email, first_name, last_name):
            self.email = email
            return True
        
        else:
            self.view.message = ("Invalid credentials")
            self.view.showMessage.emit()
            return False
    
    def reset_password(self, new_password, confirm_password):
        if not self.validate_password(new_password):
            return False
        elif new_password == confirm_password:
            self.user_db.update_password(self.email, new_password)
            self.view.message = ("Password reset successful")
            self.view.showMessage.emit()
            return True
        else:
            self.view.message = ("Passwords do not match")
            self.view.showMessage.emit()
            return False

    
    def save_to_database(self, email, first_name, last_name, password):
        self.user_db.insert_user(email, first_name, last_name, password)
    
    def email_exists(self, email):
        if self.user_db.email_exists(email):
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
        liked_track_uris = self.user_db.get_user_liked_track_uris(self.user_id)
        if not liked_track_uris:
            print('No liked tracks')
            track_uris = self.cbf.random_uri()
        else:
            print('Liked tracks')
            
            track_uris_with_opinions = self.user_db.get_user_track_uris_with_opinions(self.user_id)
            track_uris = self.user_db.get_user_track_uris(self.user_id)
            indices, _ = self.cbf.get_similarities(track_uris_with_opinions)
            track_uris = [uri for uri in self.cbf.get_uris(indices) if uri not in track_uris]

        track_details_list = self.spotify_client.get_track_details(track_uris)
        return track_details_list
    def get_preview_url(self, track_name, artist_name):
        return self.spotify_client.get_preview_url(track_name, artist_name)
    
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
            self.user_db.save_opinions(self.user_id, track_uri, opinion, self.cbf.get_index(track_uri))

    def get_track_details_by_uri(self, track_uri):
        # Implement logic to get track details by URI
        if self.cbf.search_tracks_by_uri(track_uri):
            opinions = self.user_db.get_opinions_by_uris([track_uri])
            return self.spotify_client.get_track_details([track_uri]), opinions
        
        else:
            return [], []
    
    def get_track_details_by_uris(self, track_uris):
        # Implement logic to get track details by URI
        return self.spotify_client.get_track_details(track_uris)


    def get_track_details_by_name(self, track_name):
        # Implement logic to get track details by name
        success, track_uris = self.cbf.search_tracks_by_name(track_name)
        opinions = self.user_db.get_opinions_by_uris(track_uris)
        if success:
            return self.spotify_client.get_track_details(track_uris), opinions
        
        return [], []
    
    def get_user_accounts(self):
        pass

    def on_connect_spotify_clicked(self):
        return self.spotify_client.connect_spotify()       
    
    def handle_spotify_callback(self, response_url):
        self.spotify_client.handle_spotify_callback(response_url)
    
    def update_track_database(self):
        self.cbf.update_track_database()
    
    def clean_spotify_dataset(self, folder_path):
        if folder_path.startswith("file:///"):
            folder_path = folder_path[8:] 
        self.processor.directory = sorted(glob.glob(folder_path + r"/*json"), key=len)
        print(folder_path)
        print(sorted(glob.glob(folder_path + r"/*json"), key=len))
        self.processor.clean_data()

    def get_spotify_dataset_audio_features(self, csv_file):
        if csv_file.startswith("file:///"):
            csv_file = csv_file[8:] 
        self.processor.csv_file = csv_file
        self.processor.get_audio_features(get_file_path("audio_features.csv"))
    
    def create_full_dataset(self, full_dataset_files):
        self.processor.audio_features_file = full_dataset_files[0]
        self.processor.csv_file = full_dataset_files[1]
        self.processor.join_dataset()
    
    def get_user_tracks_with_opinions(self):
        return self.user_db.get_user_tracks_with_opinions(self.user_id)

    def on_recommendation_clicked(self,opinion):
        if self.view.track_uri:
            self.save_opinion(self.view.track_uri, opinion)
        
        self.view.index = 0
        self.view.track_details_list = self.fetch_track_details()
        track_details_dict = self.view.track_details_list[self.view.index]
        self.view.index +=1
        self.view.update_track_details(track_details_dict)

    def on_bookmarks_clicked(self):
        user_saved_uris_with_opinions_dict = self.get_user_tracks_with_opinions()
        if user_saved_uris_with_opinions_dict:
            uris = [uri[0] for uri in user_saved_uris_with_opinions_dict]
            opinions = {uri[0]: uri[1] for uri in user_saved_uris_with_opinions_dict}
            track_details_list = self.get_track_details_by_uris(uris)

            for track in track_details_list:
                track_uri = track["track_uri"]
                track["opinion"] = opinions.get(track_uri, None)

            return track_details_list

        else:
            return None
    
    def search(self, search_query):
        if search_query.startswith("spotify:track:"):
            # Handle track URI search
            track_details_list, opinions = self.get_track_details_by_uri(search_query)

            if not opinions:
                opinions = [(track["track_uri"], None) for track in track_details_list]

            if track_details_list and opinions:

                opinions = {uri[0]: uri[1] for uri in opinions}
                for track in track_details_list:
                    track_uri = track["track_uri"]
                    track["opinion"] = opinions.get(track_uri, None)
                return track_details_list
            
            else: 
                return []

        elif search_query.endswith("@brookeweston.org"):
            pass

        elif search_query == " ":
            return []

        else:
            # Handle track name search
            track_details_list, opinions = self.get_track_details_by_name(search_query)

            if not opinions:
                opinions = [(track["track_uri"], None) for track in track_details_list]

            if track_details_list and opinions:
                
                opinions = {uri[0]: uri[1] for uri in opinions}

                for track in track_details_list:
                    track_uri = track["track_uri"]
                    track["opinion"] = opinions.get(track_uri, None)
                return track_details_list
            
            else:
                return []
    
    def searchBookmarks(self, search_query, filter):
        track_details_list = self.filter_saved_tracks(filter)
        if search_query.startswith("spotify:track:"):
            # Handle track URI search
            track_details_list = [track for track in track_details_list if track.get("track_uri") == search_query]
            return track_details_list
        
        elif search_query.endswith("@brookeweston.org"):
            pass

        else:
            track_details_list = [track for track in track_details_list if search_query.lower() in track.get("track_name").lower()]
            return track_details_list

        
    def filter_saved_tracks(self, filter):
        if filter == "Liked":
            track_details_list = [track for track in self.view.saved_track_details_list if track.get("opinion") == "1"]
            return track_details_list

        elif filter == "Disliked":
            track_details_list = [track for track in self.view.saved_track_details_list if track.get("opinion") == "0"]
            return track_details_list

        else:
            return self.view.saved_track_details_list
        
    def get_username(self):
        return self.user_db.get_username(self.user_id)
    
    def get_currently_playing(self):
        return self.spotify_client.get_currently_playing()
    
    def get_top_genres(self):
        return self.spotify_client.get_top_genres()
    
    def get_top_artists(self):
        return self.spotify_client.get_top_artists()
    
    def collect_all_track_uris(self):
        self.spotify_client.collect_all_track_uris()
        
            





    

        

        
    
    
    
    

