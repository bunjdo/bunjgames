import datetime
import random
from bs4 import BeautifulSoup
import requests
import re
import traceback
import json
from lxml import etree
from collections import OrderedDict


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


def create_games_from_json(path):
    def normalize_answers(_answers):
        result = []
        for i, answer in enumerate(_answers):
            n = len(_answers)
            multiplier = 100 / ((n * (n + 1)) / 2)
            val = int((len(_answers) - i) * multiplier)
            if isinstance(answer, list):
                result.append((answer[0], val))
            else:
                result.append((answer, val))
        return result

    def process_game_pack(_data: dict):
        _data_to_remove = {}

        game_xml = etree.Element('game')
        questions_xml = etree.Element('questions')
        final_questions_xml = etree.Element('final_questions')

        for question, answers in _data.items():
            norm_answers = normalize_answers(answers)
            question_xml = etree.Element('question')
            text_xml = etree.Element('text')
            text_xml.text = question
            question_xml.append(text_xml)
            for answer in norm_answers:
                answer_xml = etree.Element('answer')
                text_xml = etree.Element('text')
                text_xml.text = answer[0]
                answer_xml.append(text_xml)
                value_xml = etree.Element('value')
                value_xml.text = str(answer[1])
                answer_xml.append(value_xml)
                question_xml.append(answer_xml)

            answers_for_print = [f'{answer[0]}: {answer[1]}' for answer in norm_answers]
            print(f'{question}: {", ".join(answers_for_print)}')
            print('y - Accept\nd - Decline and remove\nq - Exit\nany other key - Decline but keep\nEnter command:')
            char = getch()
            if char == 'y':
                if len(questions_xml) < 4:
                    questions_xml.append(question_xml)
                else:
                    final_questions_xml.append(question_xml)
                _data_to_remove[question] = _data[question]
            elif char == 'd':
                _data_to_remove[question] = _data[question]
            elif char == 'q':
                return False
            else:
                pass

            if len(questions_xml) >= 4 and len(final_questions_xml) >= 5:
                filename = datetime.datetime.now().strftime("%d.%m.%Y_%H:%M:%S")
                game_xml.append(questions_xml)
                game_xml.append(final_questions_xml)
                content = etree.tostring(game_xml, pretty_print=True)
                print(f'\n\n{content}\n{filename}\n\n')
                f = open(f'packs/{filename}.feud', 'w')
                f.write(content.decode("utf-8"))
                f.close()
                all(map(_data.pop, _data_to_remove))
                return True

    with open(path, 'r+') as json_file:
        data = json.load(json_file)
        is_continue = True
        while is_continue and data:
            is_continue = process_game_pack(data)
        json.dump(data, json_file, ensure_ascii=False)


def parse():
    questions = parse_100k1_biniko_com()
    items = list(questions.items())
    random.shuffle(items)
    questions = OrderedDict(items)
    with open('parsed_data/100k1_biniko_com.json', 'w', encoding="utf-8") as file:
        json.dump(questions, file, ensure_ascii=False)


if __name__ == '__main__':
    # parse()
    create_games_from_json('parsed_data/100k1_biniko_com.json')
