from rest_framework.generics import ListAPIView

from common.serializers import GameTypeSerializer
from feud.models import Game as FeudGame
from jeopardy.models import Game as JeopardyGame
from weakest.models import Game as WeakestGame


class AvailableGamesListApi(ListAPIView):
    serializer_class = GameTypeSerializer

    def get_queryset(self):
        result = []
        token = self.kwargs['token']
        if FeudGame.objects.filter(token=token).exists():
            result.append(dict(type="feud"))
        if JeopardyGame.objects.filter(token=token).exists():
            result.append(dict(type="jeopardy"))
        if WeakestGame.objects.filter(token=token).exists():
            result.append(dict(type="weakest"))
        return result
