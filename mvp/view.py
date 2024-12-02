# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Slot, Signal
from presenter import Presenter

class Backend(QObject):

    def __init__(self):
        super().__init__()
        self.presenter = Presenter(self)
    

    @Slot(str, str)
    def on_login_clicked(self, username, password):
        self.presenter.on_login_clicked(username, password)

    @Slot(str, str)
    def on_register_clicked(self, username, password):
        self.presenter.on_register_clicked(username, password)

    def update_status(self, message):
        print(message)


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