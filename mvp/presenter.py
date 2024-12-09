from PySide6.QtCore import QObject, Slot
from model import Database
import re

class Presenter(QObject):
    def __init__(self, view):
        super().__init__()
        self.view = view
        self.user_db = Database()

    
    def on_login_clicked(self, email, password):
        if email and password:
            if self.user_db.verify_user(email, password):
                return True
            
            else:
                self.view.message = ("Invalid credentials")
                self.view.showMessage.emit()
                return False
        
        else:
            self.view.message = ("Please enter email and password")
            self.view.showMessage.emit()
            return False

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