# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path


from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal, Property
from presenter import Presenter

class Backend(QObject):
    showMessage = Signal()
    trackNameChanged = Signal()
    albumImageChanged = Signal()
    mediaPlayer_sourceChanged = Signal()
    likeButtonSourceChanged = Signal()
    dislikeButtonSourceChanged = Signal()


    def __init__(self):
        super().__init__()
        self.presenter = Presenter(self)
        self.message = ""
        self.index = 1
        self._trackName = ""
        self._albumImage = ""
        self._mediaPlayerSource = ""
        self.track_uri = ""
        self._likeButtonSource = "assets/loveGreyIcon.svg"  # Initialize the attribute
        self._dislikeButtonSource = "assets/dislikeGreyIcon.svg"  # Initialize the attribute
        self.track_details_list = []
    
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

    @Slot(str, str, result=bool)
    def on_login_clicked(self, email, password):
        success, random_track, self.track_details_list = self.presenter.on_login_clicked(email, password)

        if success:
            self.update_track_details(random_track)

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

    @Slot(str, str)
    def on_register_submit(self, first_name, last_name):
        self.presenter.on_register_submit(self.email, first_name, last_name, self.password)
    
    
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
        self.mediaPlayer_source = track_details["preview_url"]
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
    
    @Slot()
    def on_recommendation_clicked(self):
        self.index = 0
        self.track_details_list = self.presenter.fetch_track_details()
        track_details_dict = self.track_details_list[self.index]
        self.index +=1
        self.update_track_details(track_details_dict)
    

if __name__ == "__main__":
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
    
    sys.exit(app.exec())