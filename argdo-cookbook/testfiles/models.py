class User:
    def __init__(self, name, email):
        self.name = name
        self.email = email

    # TODO: add validation for email format
    def save(self):
        print(f"saving {self.name}")
