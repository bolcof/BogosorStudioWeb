(() => {
  function initialize() {
    const catalog = document.getElementById('pitch-translations');
    if (!catalog || window.NyctoPitch) return;
    const translations = new Map(JSON.parse(catalog.textContent));
    const originalText = new WeakMap();
    const originalAttributes = new WeakMap();
    const normalize = value => value.trim().replace(/\s+/g, ' ');
    const translate = (value, language) => language === 'en' ? translations.get(normalize(value)) ?? value : value;

    function setLanguage(language) {
      if (language !== 'ja' && language !== 'en') return;
      const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, {
        acceptNode: node => node.parentElement?.closest('script,style,[data-language-switcher]') ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT,
      });
      let node;
      while ((node = walker.nextNode())) {
        if (!originalText.has(node)) originalText.set(node, node.nodeValue);
        node.nodeValue = translate(originalText.get(node), language);
      }
      for (const element of document.querySelectorAll('[alt],[title],[aria-label],meta[name="description"]')) {
        if (element.closest('[data-language-switcher]')) continue;
        if (!originalAttributes.has(element)) {
          originalAttributes.set(element, ['alt', 'title', 'aria-label', 'content'].filter(name => element.hasAttribute(name)).map(name => [name, element.getAttribute(name)]));
        }
        for (const [name, value] of originalAttributes.get(element)) element.setAttribute(name, translate(value, language));
      }
      document.documentElement.lang = language;
      for (const button of document.querySelectorAll('[data-pitch-language]')) button.setAttribute('aria-pressed', String(button.dataset.pitchLanguage === language));
    }

    document.addEventListener('click', event => {
      const button = event.target.closest?.('button[data-pitch-language]');
      if (button) setLanguage(button.dataset.pitchLanguage);
    });
    window.NyctoPitch = { setLanguage };
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initialize, { once: true });
  else initialize();
})();
