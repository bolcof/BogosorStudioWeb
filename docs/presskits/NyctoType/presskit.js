(() => {
  function setLanguage(language) {
    if (!['ja', 'en'].includes(language)) return;
    document.documentElement.lang = language;
    for (const element of document.querySelectorAll('[data-ja][data-en]')) element.textContent = element.dataset[language];
    for (const element of document.querySelectorAll('[data-alt-ja]')) {
      const text = element.getAttribute(`data-alt-${language}`);
      element.setAttribute(element.tagName === 'IMG' ? 'alt' : 'aria-label', text);
    }
    for (const element of document.querySelectorAll('[data-meta-ja]')) element.content = element.getAttribute(`data-meta-${language}`);
    for (const button of document.querySelectorAll('[data-language]')) button.setAttribute('aria-pressed', String(button.dataset.language === language));
    document.querySelector('.press-nav').setAttribute('aria-label', language === 'ja' ? 'プレスキット' : 'Press kit');
  }
  for (const button of document.querySelectorAll('[data-language]')) button.addEventListener('click', () => setLanguage(button.dataset.language));
  if (new URLSearchParams(location.search).get('lang') === 'en') setLanguage('en');
})();
