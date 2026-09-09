import json
import re
import sys
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class CopyCatalog(HTMLParser):
    def __init__(self):
        super().__init__()
        self.skip = False
        self.strings = {}

    def add(self, value):
        value = re.sub(r'\s+', ' ', value.strip())
        if re.search(r'[\u3040-\u30ff\u3400-\u9fff]', value) and value != '日本語':
            self.strings[value] = None

    def handle_starttag(self, tag, attrs):
        if tag in ('script', 'style'):
            self.skip = True
        attributes = dict(attrs)
        for name in ('alt', 'title', 'aria-label'):
            if name in attributes:
                self.add(attributes[name])
        if tag == 'meta' and attributes.get('name') == 'description':
            self.add(attributes['content'])

    def handle_endtag(self, tag):
        if tag in ('script', 'style'):
            self.skip = False

    def handle_data(self, value):
        if not self.skip:
            self.add(value)


parser = CopyCatalog()
parser.feed((ROOT / 'output/html/NyctoType-Pitch.html').read_text())
if len(sys.argv) == 3 and sys.argv[1] == '--extract':
    Path(sys.argv[2]).write_text(json.dumps(list(parser.strings), ensure_ascii=False, indent=2))
    print(json.dumps(dict(enumerate(parser.strings)), ensure_ascii=False, indent=2))
else:
    entries = json.loads((ROOT / 'app/english-copy.json').read_text())
    translations = dict(entries)
    assert len(translations) == len(entries), 'Duplicate translation keys'
    missing = [value for value in parser.strings if value not in translations]
    assert not missing, f'Missing translations: {missing}'
    assert all(isinstance(value, str) and value.strip() for value in translations.values())
    assert not any(re.search(r'[\u3040-\u30ff\u3400-\u9fff]', value) for value in translations.values()), 'Japanese remains in English copy'
    print(f'English coverage: {len(parser.strings)} strings; no missing translations')
