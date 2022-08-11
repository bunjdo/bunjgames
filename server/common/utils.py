import hashlib
import os
import shutil
import string
import traceback
import typing
import zipfile
import logging
from pathlib import Path
from urllib.parse import unquote
from pydub import AudioSegment

from rest_framework.exceptions import APIException
from django.conf import settings
from hashids import Hashids


logger = logging.getLogger(__name__)


class BadFormatException(APIException):
    status_code = 400


class BadStateException(APIException):
    status_code = 400


class NothingToDoException(APIException):
    status_code = 400


def unzip(filename, extract_dir):
    with zipfile.ZipFile(filename) as archive:
        for entry in archive.infolist():
            name = unquote(entry.filename)

            # don't extract absolute paths or ones with .. in them
            if name.startswith('/') or '..' in name:
                continue

            target = os.path.join(extract_dir, *name.split('/'))
            os.makedirs(os.path.dirname(target), exist_ok=True)
            if not entry.is_dir():  # file
                with archive.open(entry) as source, open(target, 'wb') as dest:
                    shutil.copyfileobj(source, dest)


hashids = Hashids(salt=settings.SECRET_KEY, min_length=6, alphabet=string.ascii_uppercase + string.digits)


def generate_token(id):
    return hashids.encode(id)


def game_assets_post_process(parent: str) -> typing.Dict[str, str]:
    if not settings.GAME_ASSETS_POST_PROCESS:
        logger.debug("Game file post-processing is disabled, skipping.")
        return {}

    path_list = Path(parent).rglob('*.*')
    transform_dict = {}

    for path in filter(lambda p: str(p).endswith((".mp3", ".wav", ".flac", ".ogg", ".opus")), path_list):
        path_str = str(path)
        m = hashlib.sha256()
        m.update(path_str.encode())
        target_filename = m.hexdigest() + ".mp3"
        target_path = os.path.join(parent, target_filename)

        try:
            audio = AudioSegment.from_file(path_str)

            gain = audio.dBFS - (-14)
            audio = audio.remove_dc_offset()
            audio = audio.apply_gain(-gain)
            # this code is too slow to be executed in real time
            # audio = audio.compress_dynamic_range()
            audio.export(target_path, format="mp3")

            path.unlink()
        except Exception:
            traceback.print_exc()
        finally:
            transform_dict[os.path.relpath(path_str, parent)] = target_filename

    return transform_dict
