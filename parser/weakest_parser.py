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


def parse_100k1_biniko_com():
    questions = {}
    BASE_URL = 'http://web.archive.org/web/20190202203822/http://100k1.biniko.com'

    def parse_text(text, delimiter='\n'):
        def parse_text_item(item):
            item = re.sub(r'\d\.', '', item).replace('-', '').strip()
            value = re.search(r'\.*(\d+)', item)
            if value:
                value = value.group(0)
                item = item.replace(value, '').strip()
                return item, value
            return item
        return [parse_text_item(item) for item in text.split(delimiter) if item.strip()]

    def parse_item(question, url):
        try:
            soup = BeautifulSoup(
                requests.get(f'{BASE_URL}/{url}').text,
                'lxml'
            )
            text = soup.find(class_='otvet').text.strip()
            parsed_text = parse_text(text)
            if len(parsed_text) <= 1:
                parsed_text = parse_text(text, delimiter=',')
                if len(parsed_text) <= 1:
                    return
            print(question, parsed_text)
            questions[question] = parsed_text
        except Exception:
            print(traceback.format_exc())

    soup = BeautifulSoup(
        requests.get(f'{BASE_URL}/list100k1.php').text,
        'lxml'
    )
    for a in soup.find(id='content_otvet').children:
        parse_item(a.get_text(strip=True), a.get('href'))
    return questions


def create_games_from_file(path, divider='|'):
    def process_game_pack(_data: list):
        game_xml = etree.Element('game')
        questions_xml = etree.Element('questions')
        final_questions_xml = etree.Element('final_questions')

        for line in _data:
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

    with open(path, 'r') as file:
        lines = file.readlines()
        process_game_pack(lines)
        json.dump(lines, path, ensure_ascii=False)


def process():
    create_games_from_file('parsed_data/baza-voprosov-dlya-viktoriny.txt', '|')


if __name__ == '__main__':
    process()
