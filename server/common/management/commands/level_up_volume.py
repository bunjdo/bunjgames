import os
import traceback

from django.core.management.base import BaseCommand
from pathlib import Path

from pydub import AudioSegment


class Command(BaseCommand):

    def add_arguments(self, parser):
        parser.add_argument('input', type=str)
        parser.add_argument('output', type=str)

    def handle(self, *args, **kwargs):
        input = kwargs['input']
        input_list = Path(input).rglob("*.*")
        output = kwargs['output']

        for path in filter(lambda p: str(p).endswith((".mp3", ".wav", ".flac", ".ogg", ".opus")), input_list):
            path_str = str(path)
            try:
                audio = AudioSegment.from_file(path_str)
                audio = audio.remove_dc_offset()

                gain = audio.dBFS - (-14)
                audio = audio.apply_gain(-gain)

                rel = os.path.relpath(path_str, input)
                filename = os.path.join(output, rel)
                os.makedirs(os.path.dirname(filename), exist_ok=True)
                audio.export(filename, format="mp3")

                path.unlink()
            except Exception:
                traceback.print_exc()
