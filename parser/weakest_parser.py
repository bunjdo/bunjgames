import datetime

from bs4 import BeautifulSoup
import requests
import re
import traceback
import json
from lxml import etree


class _Getch:
    """Gets a single character from standard input.  Does not echo to the screen."""
    def __init__(self):
        try:
            self.impl = _GetchWindows()
        except ImportError:
            self.impl = _GetchUnix()

    def __call__(self): return self.impl()


class _GetchUnix:
    def __init__(self):
        import tty, sys

    def __call__(self):
        import sys, tty, termios
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch


class _GetchWindows:
    def __init__(self):
        import msvcrt

    def __call__(self):
        import msvcrt
        return msvcrt.getch()


getch = _Getch()


def create_games_from_file(path, divider='|'):
    def process_game_pack(_data: list):
        game_xml = etree.Element('game')
        questions_xml = etree.Element('questions')
        final_questions_xml = etree.Element('final_questions')

        _index = 0
        for _index, line in enumerate(_data):
            question_xml = etree.Element('question')
            q, a = line.split(divider)
            question_question_xml = etree.Element('question')
            question_question_xml.text = q
            question_xml.append(question_question_xml)
            answer_xml = etree.Element('answer')
            answer_xml.text = a
            question_xml.append(answer_xml)

            print(f'{q}: {a}')
            print('y - Accept\nd - Decline')
            char = getch()
            if char == 'y':
                if len(questions_xml) < 200:
                    questions_xml.append(question_xml)
                else:
                    final_questions_xml.append(question_xml)
            elif char == 'd':
                continue

            if len(questions_xml) >= 200 and len(final_questions_xml) >= 16:
                score_multiplier_xml = etree.Element('score_multiplier')
                score_multiplier_xml.text = '1'

                filename = datetime.datetime.now().strftime("%d.%m.%Y_%H:%M:%S")
                game_xml.append(questions_xml)
                game_xml.append(final_questions_xml)
                game_xml.append(score_multiplier_xml)
                content = etree.tostring(game_xml, pretty_print=True)
                print(f'\n\n{content}\n{filename}\n\n')
                f = open(f'packs/{filename}.weakest', 'w')
                f.write(content.decode("utf-8"))
                f.close()
        return _index

    with open(path, 'r+') as file:
        lines = file.readlines()
        index = process_game_pack(lines)
        json.dump(lines[index:], file, ensure_ascii=False)


def process():
    create_games_from_file('parsed_data/baza-voprosov-dlya-viktoriny.txt', '|')


if __name__ == '__main__':
    process()
