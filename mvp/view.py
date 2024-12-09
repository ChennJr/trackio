# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path


from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal
from presenter import Presenter

class Backend(QObject):
    showMessage = Signal()

    def __init__(self):
        super().__init__()
        self.presenter = Presenter(self)
        self.email = ""
        self.password = ""
        self.message = ""
    

    @Slot(str, str, result=bool)
    def on_login_clicked(self, email, password):
        return self.presenter.on_login_clicked(email, password)

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

    @Slot(result=str)
    def update_status(self):
        return self.message
        
        


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