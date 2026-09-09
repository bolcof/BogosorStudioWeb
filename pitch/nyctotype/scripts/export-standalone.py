from base64 import b64encode
from html import escape
from html.parser import HTMLParser
from pathlib import Path
import mimetypes

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / 'dist/client'
OUTPUT = ROOT / 'output/html/NyctoType-Pitch.html'


def embedded(path):
    file = BUILD / path.lstrip('/')
    mime = mimetypes.guess_type(file.name)[0] or 'application/octet-stream'
    return f'data:{mime};base64,' + b64encode(file.read_bytes()).decode('ascii')


class Standalone(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=False)
        self.output = []
        self.skip_script = False
        self.keep_script = False
        self.image_links = []
        self.slot_count = 0

    def handle_decl(self, decl):
        self.output.append(f'<!{decl}>')

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'script':
            if attrs.get('data-pitch-script') == 'translations':
                self.keep_script = True
                self.emit(tag, attrs)
                return
            if attrs.get('data-pitch-script') == 'runtime':
                runtime = (ROOT / 'public/language-switcher.js').read_text()
                self.output.append('<script data-pitch-script="runtime">' + runtime + '</script>')
            self.skip_script = True
            return
        if self.skip_script:
            return
        if tag == 'figure' and 'data-slot' in attrs:
            self.slot_count += 1
        if tag == 'link':
            if attrs.get('rel') == 'stylesheet':
                css = (BUILD / attrs['href'].lstrip('/')).read_text()
                self.output.append('<style>' + css + '</style>')
            elif attrs.get('rel') in ('icon', 'shortcut icon'):
                attrs['href'] = embedded(attrs['href'])
                self.emit(tag, attrs)
            return
        if tag == 'img' and attrs.get('src', '').startswith('/'):
            attrs['src'] = embedded(attrs['src'])
            attrs.pop('srcset', None)
            attrs.pop('loading', None)
        if tag == 'a':
            is_image = attrs.get('href', '').startswith('/images/')
            self.image_links.append(is_image)
            if is_image:
                return
        if tag == 'button' and 'print-button' in attrs.get('class', ''):
            attrs['onclick'] = 'window.print()'
        if tag == 'button' and 'data-open-dialog' in attrs:
            attrs['onclick'] = "document.getElementById(this.dataset.openDialog).showModal()"
        if tag == 'dialog' and 'data-dismiss-backdrop' in attrs:
            attrs['onclick'] = "if(event.target===this){const r=this.getBoundingClientRect();if(event.clientX<r.left||event.clientX>r.right||event.clientY<r.top||event.clientY>r.bottom)this.close()}"
        self.emit(tag, attrs)

    def emit(self, tag, attrs):
        values = ''.join(' ' + key + ('' if value is None else '="' + escape(value, quote=True) + '"') for key, value in attrs.items())
        self.output.append('<' + tag + values + '>')

    def handle_endtag(self, tag):
        if tag in ('link', 'meta', 'img', 'br', 'hr', 'input', 'source'):
            return
        if tag == 'script':
            if self.keep_script:
                self.output.append('</script>')
                self.keep_script = False
            self.skip_script = False
            return
        if self.skip_script:
            return
        if tag == 'a' and self.image_links.pop():
            return
        self.output.append('</' + tag + '>')

    def handle_data(self, data):
        if not self.skip_script:
            self.output.append(data)

    def handle_entityref(self, name):
        if not self.skip_script:
            self.output.append('&' + name + ';')

    def handle_charref(self, name):
        if not self.skip_script:
            self.output.append('&#' + name + ';')


parser = Standalone()
parser.feed((BUILD / 'index.html').read_text())
html = ''.join(parser.output)
assert html.count('<script') == 2
assert 'src="/language-switcher.js"' not in html
assert 'id="pitch-translations"' in html
assert html.count('data-pitch-language=') == 2
assert 'src="/' not in html
assert 'href="/_next/' not in html
assert html.count('data-chapter=') == 23
assert 'href="#active"' not in html
assert parser.slot_count == 9
assert html.count('data-open-dialog="update-history-dialog"') == 1
assert html.count('id="update-history-dialog"') == 1
assert 'method="dialog"' in html
assert 'document.getElementById(this.dataset.openDialog).showModal()' in html
OUTPUT.parent.mkdir(parents=True, exist_ok=True)
OUTPUT.write_text(html)
print(f'{OUTPUT}\n{OUTPUT.stat().st_size:,} bytes; cover + 23 chapters; 9 image slots')
