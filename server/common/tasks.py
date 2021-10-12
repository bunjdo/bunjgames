import os
import shutil

from django.conf import settings
from django.db import transaction
from django.utils import timezone

from whirligig.models import Game as WhirligigGame
from jeopardy.models import Game as JeopardyGame
from weakest.models import Game as WeakestGame
from feud.models import Game as FeudGame

from server.celery import app


@app.task
@transaction.atomic()
def cleanup():
    expired_whirligig_games = WhirligigGame.objects.filter(expired__lt=timezone.now())
    for game in expired_whirligig_games.iterator():
        shutil.rmtree(os.path.join(settings.MEDIA_ROOT_WHIRLIGIG, game.token), ignore_errors=True)
    expired_whirligig_games.delete()

    expired_jeopardy_games = JeopardyGame.objects.filter(expired__lt=timezone.now())
    for game in expired_jeopardy_games.iterator():
        shutil.rmtree(os.path.join(settings.MEDIA_ROOT_JEOPARDY, game.token), ignore_errors=True)
    expired_jeopardy_games.delete()

    WeakestGame.objects.filter(expired__lt=timezone.now()).delete()
    FeudGame.objects.filter(expired__lt=timezone.now()).delete()
