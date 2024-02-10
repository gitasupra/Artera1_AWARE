# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import db_fn, https_fn
from firebase_admin import initialize_app, db

app =initialize_app()
#
#
# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")

# All Realtime Database instances in default function region us-central1 at path "/user/{uid}"
# There must be at least one Realtime Database present in us-central1.
# @db_fn.on_value_written(r"/user/{uid}")
# def onwrittenfunctiondefault(event: db_fn.Event[db_fn.Change]):
#     # ...
#     pass

# Instance named "my-app-db-2", at path "/test/{uid}".
# The "my-app-db-2" instance must exist in this region.
#the bl
# @db_fn.on_value_written(
#     reference=r"/test/",
#     instance="my-app-db-2",
#     # This example assumes us-central1
# )

@db_fn.on_value_created(reference="/test/{pushId}/original")
def makeuppercase(event: db_fn.Event[any]) -> None:
    """Listens for new messages added to /messages/{pushId}/original and
    creates an uppercase version of the message to /messages/{pushId}/uppercase
    """

    # Grab the value that was written to the Realtime Database.
    original = event.data
    if not isinstance(original, str):
        print(f"Not a string: {event.reference}")
        return

    # Use the Admin SDK to set an "uppercase" sibling.
    print(f"Uppercasing {event.params['pushId']}: {original}")
    upper = original.upper()
    parent = db.reference(event.reference).parent
    if parent is None:
        print("Message can't be root node.")
        return
    parent.child("uppercase").set(upper)

# def on_written_function_instance(event: db_fn.Event[db_fn.Change]):
#     # ...
#     pass

# # Instance with "my-app-db-" prefix, at path "/user/{uid}", where uid ends with @gmail.com.
# # There must be at least one Realtime Database with "my-app-db-*" prefix in this region.
# @db_fn.on_value_written(
#     reference=r"/user/{uid=*@gmail.com}",
#     instance="my-app-db-*",
#     # This example assumes us-central1, but to set location:
#     # region="europe-west1",
# )
# def on_written_function_instance(event: db_fn.Event[db_fn.Change]):
#     # ...
#     pass