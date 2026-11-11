(() => {
  const cards = [...document.querySelectorAll('.archive-card')];
  const filters = document.querySelector('.news-filters');
  if (!filters) return;
  const groups = ['work', 'category'];
  const choices = Object.fromEntries(groups.map(group => [group, new Map(cards.map(card => [card.dataset[group], card.dataset[`${group}Label`]]))]));
  const selected = { work: '', category: '' };
  const count = document.querySelector('#news-count');
  const clear = document.querySelector('#clear-filters');
  const empty = document.querySelector('.news-empty');

  function render() {
    let visible = 0;
    for (const card of cards) {
      card.hidden = !groups.every(group => !selected[group] || card.dataset[group] === selected[group]);
      if (!card.hidden) visible++;
    }
    for (const button of filters.querySelectorAll('[data-filter]')) {
      button.setAttribute('aria-pressed', String(selected[button.dataset.filter] === button.dataset.value));
    }
    const labels = groups.filter(group => selected[group]).map(group => choices[group].get(selected[group]));
    count.textContent = `${labels.length ? labels.join(' / ') : 'すべてのお知らせ'} — ${visible}件`;
    empty.hidden = visible !== 0;
    clear.hidden = labels.length === 0;
  }

  function readLocation() {
    const params = new URLSearchParams(location.search);
    for (const group of groups) {
      const value = params.get(group) || '';
      selected[group] = choices[group].has(value) ? value : '';
    }
    render();
  }

  function change(group, value) {
    if (group) selected[group] = value;
    else groups.forEach(key => { selected[key] = ''; });
    const url = new URL(location.href);
    for (const key of groups) {
      if (selected[key]) url.searchParams.set(key, selected[key]);
      else url.searchParams.delete(key);
    }
    if (url.href !== location.href) history.pushState(null, '', url);
    render();
  }

  for (const group of groups) {
    const container = filters.querySelector(`[data-filter-group="${group}"]`);
    for (const [value, label] of [['', 'すべて'], ...choices[group]]) {
      const button = document.createElement('button');
      button.type = 'button';
      button.dataset.filter = group;
      button.dataset.value = value;
      button.textContent = label;
      button.addEventListener('click', () => change(group, value));
      container.append(button);
    }
  }
  for (const link of document.querySelectorAll('.archive-card .news-tag')) {
    link.addEventListener('click', event => {
      if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
      event.preventDefault();
      const group = link.dataset.tagKind;
      change(group, new URL(link.href).searchParams.get(group));
    });
  }
  clear.addEventListener('click', () => change());
  window.addEventListener('popstate', readLocation);
  filters.hidden = false;
  readLocation();
})();
