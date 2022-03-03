from django.urls import path

from common import api

urlpatterns = [
    path('games/<str:token>/available', api.AvailableGamesListApi.as_view()),
]
