from bs4 import BeautifulSoup
import requests
import re
import traceback
import json


questions_100k1_biniko_com = {}


def parse_100k1_biniko_com():
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
            questions_100k1_biniko_com[question] = parsed_text
        except Exception:
            print(traceback.format_exc())

    soup = BeautifulSoup(
        requests.get(f'{BASE_URL}/list100k1.php').text,
        'lxml'
    )
    for a in soup.find(id='content_otvet').children:
        parse_item(a.get_text(strip=True), a.get('href'))


if __name__ == '__main__':
    parse_100k1_biniko_com()
    with open('parsed_data/100k1_biniko_com.json', 'w', encoding="utf-8") as file:
        json.dump(questions_100k1_biniko_com, file, ensure_ascii=False)
