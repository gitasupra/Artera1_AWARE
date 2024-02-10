from firebase_functions import db_fn, https_fn
from firebase_admin import initialize_app, db

app=initialize_app()

@db_fn.on_value_written(r"/user/{uid}")
def onwrittenfunctiondefault(event: db_fn.Event[db_fn.Change]):
    # ...
    pass