# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal, Property, QUrl


from presenter import Presenter
import cProfile
from PySide6.QtWebEngineQuick import QtWebEngineQuick

class Backend(QObject):
    showMessage = Signal()
    trackNameChanged = Signal()
    albumImageChanged = Signal()
    mediaPlayer_sourceChanged = Signal()
    likeButtonSourceChanged = Signal()
    dislikeButtonSourceChanged = Signal()
    searchResultsLengthChanged = Signal()
    authUrlChanged = Signal()
    accountTypeChanged = Signal()


    def __init__(self):
        super().__init__()
        self.presenter = Presenter(self)
        self.message = ""
        self.index = 1
        self._trackName = ""
        self._albumImage = ""
        self._mediaPlayerSource = ""
        self.track_uri = ""
        self._searchResultsLength = 0
        self._likeButtonSource = "assets/loveGreyIcon.svg"  # Initialize the attribute
        self._dislikeButtonSource = "assets/dislikeGreyIcon.svg"  # Initialize the attribute
        self.track_details_list = []
        self._auth_url = "google.com"
        self._account_type = ""
        self.saved_track_details_list = []
    
    @Property(str, notify=trackNameChanged)
    def trackName(self):
        return self._trackName
    
    @trackName.setter
    def trackName(self, value):
        if self._trackName != value:
            self._trackName = value
            self.trackNameChanged.emit()
    
    @Property(str, notify=albumImageChanged)
    def albumImage(self):
        return self._albumImage
    
    @albumImage.setter
    def albumImage(self, value):
        if self._albumImage != value:
            self._albumImage = value
            self.albumImageChanged.emit()
    
    @Property(str, notify=mediaPlayer_sourceChanged)
    def mediaPlayer_source(self):
        return self._mediaPlayerSource
    
    @mediaPlayer_source.setter
    def mediaPlayer_source(self, value):
        if self._mediaPlayerSource != value:
            self._mediaPlayerSource = value
            self.mediaPlayer_sourceChanged.emit()
    
    @Property(str, notify=likeButtonSourceChanged)
    def likeButtonSource(self):
        return self._likeButtonSource
        
    @likeButtonSource.setter
    def likeButtonSource(self, value):
        if self._likeButtonSource != value:
            self._likeButtonSource = value
            self.likeButtonSourceChanged.emit()
    
    @Property(str, notify=dislikeButtonSourceChanged)
    def dislikeButtonSource(self):
        return self._dislikeButtonSource
    
    @dislikeButtonSource.setter
    def dislikeButtonSource(self, value):
        if self._dislikeButtonSource != value:
            self._dislikeButtonSource = value
            self.dislikeButtonSourceChanged.emit()

    @Property(str, notify=authUrlChanged)
    def auth_url(self):
        return self._auth_url
    
    @auth_url.setter
    def auth_url(self, value):
        if self._auth_url != value:
            self._auth_url = value
            self.authUrlChanged.emit()

    @Property(str, notify=accountTypeChanged)
    def account_type(self):
        return self._account_type

    @account_type.setter
    def account_type(self, value):
        if self._account_type != value:
            self._account_type = value
            self.accountTypeChanged.emit()

    @Slot(str, str, result=bool)
    def on_login_clicked(self, email, password):
        success, track, self.track_details_list = self.presenter.on_login_clicked(email, password)

        if success:
            self.update_track_details(track)

        return success
    
    @Slot(str, str, result=bool)
    def on_register_clicked(self, email, password):
        if not self.presenter.validate_email(email):
            return False
        
        if not self.presenter.validate_password(password):
            return False
        
        if self.presenter.email_exists(email):
            return False
        
        
        self.email = email
        self.password = password
        return True

    @Slot(str, str, result=bool)
    def on_register_submit(self, first_name, last_name):
        success, track, self.track_details_list = self.presenter.on_register_submit(self.email, first_name, last_name, self.password)
        if success:
            self.update_track_details(track)
    
        return success
    
    @Slot(str, str, str, result=bool)
    def on_reset_password_clicked(self, email, first_name, last_name):
        if self.presenter.verify_user_forgotten_password(email, first_name, last_name):
            return True
        return False
    
    @Slot(str, str, result=bool)
    def on_reset_password_submit(self, new_password, confirm_password):
        if self.presenter.reset_password(new_password, confirm_password):
            return True
         
        return False
    
    @Slot(result=dict)
    def fetch_track_details(self):
        if self.index == len(self.track_details_list):
            self.track_details_list = self.presenter.fetch_track_details()
            self.index = 0

        track_details_dict = self.track_details_list[self.index]
        self.index += 1

        return track_details_dict
    
    @Slot(result = str)
    def update_status(self):
        return self.message
    
    @Slot(dict)
    def update_track_details(self, track_details):
        self.trackName = track_details["track_name"] + " by " + track_details["artist_name"]
        self.albumImage = track_details["album_cover"]
        self.mediaPlayer_source = self.presenter.get_preview_url(track_details["track_name"], track_details["artist_name"])
        self.track_uri = track_details["track_uri"]

        opinion = self.presenter.get_opinions(track_details["track_uri"])
        self.set_opinion(opinion)
    
    def set_opinion(self, opinion):
        if opinion == 1:
            self.likeButtonSource = "assets/loveRedIcon.svg"
            self.dislikeButtonSource = "assets/dislikeGreyIcon.svg"
            
        elif opinion == 0:
            self.likeButtonSource = "assets/loveGreyIcon.svg"
            self.dislikeButtonSource = "assets/dislikeRedIcon.svg"

        else:
            self.likeButtonSource = "assets/loveGreyIcon.svg"
            self.dislikeButtonSource = "assets/dislikeGreyIcon.svg"
    
    
    @Slot(int)
    def on_swipe_up(self, opinion):
        self.presenter.save_opinion(self.track_uri, opinion)

        if self.index == len(self.track_details_list):
            self.track_details_list = self.presenter.fetch_track_details()
            self.index = 0

        track_details_dict = self.track_details_list[self.index]
        self.index += 1
        self.update_track_details(track_details_dict)
    
    @Slot(int)
    def on_recommendation_clicked(self, opinion):
        self.presenter.on_recommendation_clicked(opinion)
    
    @Slot(result=list)
    def on_bookmarks_clicked(self):
        self.saved_track_details_list = self.presenter.on_bookmarks_clicked()

        return self.saved_track_details_list
    
    @Slot(str, result=list)
    def search(self, search_query):
        return self.presenter.search(search_query)
        
    
    @Slot(str, str, result=list)
    def searchBookmarks(self, search_query, filter):
        return self.presenter.searchBookmarks(search_query, filter)
        
    @Slot(str, int)
    def search_save_opinion(self, track_uri, opinion):
        self.presenter.save_opinion(str(track_uri), opinion)

    @Slot(str, result=int)
    def get_opinions(self, track_uri):
        return self.presenter.get_opinions(track_uri)
    
    @Slot()
    def on_connect_spotify_clicked(self):
        self.auth_url = self.presenter.on_connect_spotify_clicked()
    
    @Slot(str)
    def handle_spotify_callback(self, response_url):
        self.presenter.handle_spotify_callback(response_url)
        
    @Slot()
    def update_track_database(self):
        self.presenter.update_track_database()

    @Slot(str)
    def clean_spotify_dataset(self, folder_path):
        self.presenter.clean_spotify_dataset(folder_path)
    
    @Slot(str)
    def get_spotify_dataset_audio_features(self, csv_file):
        self.presenter.get_spotify_dataset_audio_features(csv_file)
    
    @Slot(list)
    def create_full_dataset(self, full_dataset_files):
        full_dataset_files = [QUrl(url).toLocalFile() for url in full_dataset_files]
        self.presenter.create_full_dataset(full_dataset_files)
            
    @Slot(str, result=list)
    def filter_saved_tracks(self, filter):
        return self.presenter.filter_saved_tracks(filter)
    
    @Slot(result=str)
    def get_username(self):
        return self.presenter.get_username()
    
    @Slot(result=dict)
    def get_currently_playing(self):
        return self.presenter.get_currently_playing()
    
    @Slot(result=list)
    def get_top_genres(self):
        return self.presenter.get_top_genres()
    
    @Slot(result=list)
    def get_top_artists(self):
        return self.presenter.get_top_artists()
    
    @Slot()
    def collect_all_track_uris(self):
        self.presenter.collect_all_track_uris()

    

def main():
    QtWebEngineQuick.initialize()
    
    app = QGuiApplication(sys.argv)
    backend = Backend()
    
    engine = QQmlApplicationEngine()
    backend.engine = engine
    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.rootContext().setContextProperty("backend", backend)
    
    # Load the QML file and emit the signal when done
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)
    
    app.exec()

if __name__ == "__main__":
    # Create a profile file using cProfile
    profile_file = 'profile_data.prof'
    cProfile.run('main()', profile_file)

    
