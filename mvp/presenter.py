from PySide6.QtCore import QObject, Slot

class Presenter(QObject):
    def __init__(self, view):
        super().__init__()
        self.view = view

    
    def on_login_clicked(self, username, password):
        if username and password:
            self.view.update_status(f"Submitted text: {username} {password}")
        
        else:
            self.view.update_status("No text entered")
    
    
    def on_register_clicked(self, username, password):
        if username and password:
            self.view.update_status(f"Submitted text: {username} {password}")
        else:
            self.view.update_status("No text entered")

