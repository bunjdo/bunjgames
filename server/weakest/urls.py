from django.urls import path
from django.urls import re_path

from weakest import api
from weakest.consumers import WeakestConsumer

urlpatterns = [
    path('create', api.CreateGameAPI.as_view()),
    path('players/register', api.RegisterPlayerAPI.as_view()),
]

websocket_urlpatterns = [
    re_path(r'(?P<token>\w+)$', WeakestConsumer.as_asgi()),
]
