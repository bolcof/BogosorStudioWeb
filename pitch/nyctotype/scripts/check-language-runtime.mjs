import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const catalog = JSON.parse(fs.readFileSync(new URL('../app/english-copy.json', import.meta.url), 'utf8'));
const runtime = fs.readFileSync(new URL('../public/language-switcher.js', import.meta.url), 'utf8');
const normalize = value => value.trim().replace(/\s+/g, ' ');

function fixture(readyState) {
  const makeElement = (attrs = {}, excluded = false) => ({
    attrs: { ...attrs },
    closest: () => excluded ? {} : null,
    hasAttribute(name) { return name in this.attrs; },
    getAttribute(name) { return this.attrs[name]; },
    setAttribute(name, value) { this.attrs[name] = value; },
  });
  const text = catalog.map(([ja]) => ({ nodeValue: `\n${ja}\n`, parentElement: makeElement() }));
  const excluded = { nodeValue: '日本語', parentElement: makeElement({}, true) };
  const unchanged = { nodeValue: 'NyctoType / 1000', parentElement: makeElement() };
  const all = [...text, excluded, unchanged];
  const elements = ['alt', 'title', 'aria-label', 'content'].map(name => makeElement({ [name]: catalog[0][0], href: 'https://example.com/game' }));
  const buttons = ['ja', 'en'].map(language => Object.assign(makeElement(), { dataset: { pitchLanguage: language } }));
  const events = new Map();
  const document = {
    readyState, body: {}, documentElement: { lang: 'ja' },
    getElementById: () => ({ textContent: JSON.stringify(catalog) }),
    createTreeWalker(_root, _what, filter) {
      const accepted = all.filter(node => filter.acceptNode(node) === 1);
      let index = 0;
      return { nextNode: () => accepted[index++] ?? null };
    },
    querySelectorAll: selector => selector === '[data-pitch-language]' ? buttons : elements,
    addEventListener: (name, callback) => events.set(name, callback),
  };
  const window = {};
  vm.runInNewContext(runtime, { document, window, NodeFilter: { SHOW_TEXT: 4, FILTER_REJECT: 2, FILTER_ACCEPT: 1 } });
  if (readyState === 'loading') {
    assert.equal(window.NyctoPitch, undefined);
    events.get('DOMContentLoaded')();
  }
  for (const language of ['en', 'ja', 'en', 'ja']) {
    const button = buttons[language === 'en' ? 1 : 0];
    events.get('click')({ target: { closest: () => button } });
    assert.equal(document.documentElement.lang, language);
    text.forEach((node, index) => assert.equal(node.nodeValue, language === 'en' ? catalog[index][1] : `\n${catalog[index][0]}\n`));
    elements.forEach((element, index) => {
      assert.equal(element.attrs[['alt', 'title', 'aria-label', 'content'][index]], language === 'en' ? catalog[0][1] : catalog[0][0]);
      assert.equal(element.attrs.href, 'https://example.com/game');
    });
    buttons.forEach(button => assert.equal(button.attrs['aria-pressed'], String(button.dataset.pitchLanguage === language)));
    assert.equal(excluded.nodeValue, '日本語');
    assert.equal(unchanged.nodeValue, 'NyctoType / 1000');
  }
  window.NyctoPitch.setLanguage('de');
  assert.equal(document.documentElement.lang, 'ja');
  assert.equal(new Set(catalog.map(([ja]) => normalize(ja))).size, catalog.length);
}

fixture('loading');
fixture('complete');
const html = fs.readFileSync(new URL('../output/html/NyctoType-Pitch.html', import.meta.url), 'utf8');
assert(html.includes(runtime));
assert(html.includes('method="dialog"'));
assert(html.includes('window.print()'));
assert(html.includes('document.getElementById(this.dataset.openDialog).showModal()'));
assert(!/<script[^>]*\bsrc=/.test(html));
assert(html.includes('https://bolcof.github.io/BogosorStudioWeb/'));
const styles = fs.readFileSync(new URL('../app/globals.css', import.meta.url), 'utf8');
assert.match(styles, /@media print\s*\{\s*\.language-switcher\s*\{\s*display:none !important/);
console.log(`Language runtime: ${catalog.length} translations, reversible switches, labels, preserved links, offline scripts and print exclusion passed.`);
