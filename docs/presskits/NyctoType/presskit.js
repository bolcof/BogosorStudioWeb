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
  const archive = document.querySelector('#release-archive');
  for (const button of document.querySelectorAll('[data-open-release-archive]')) button.addEventListener('click', () => archive.showModal());
  archive.querySelector('[data-close-release-archive]').addEventListener('click', () => archive.close());
  archive.addEventListener('click', (event) => {
    const bounds = archive.getBoundingClientRect();
    const outside = event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom;
    if (outside) archive.close();
  });
  if (new URLSearchParams(location.search).get('lang') === 'en') setLanguage('en');
})();
