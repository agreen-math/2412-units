from sage.all import *
import random
import string

class Generator(BaseGenerator):
    def data(self):
        chars = string.ascii_uppercase + string.digits
        unique_id = "".join(random.choice(chars) for _ in range(6))
        
        return {
            "unique_id": unique_id
        }