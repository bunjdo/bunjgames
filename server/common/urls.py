from django.urls import path

from common import api

urlpatterns = [
    path('v1/games/<str:token>/available', api.AvailableGamesListApi.as_view()),
]
