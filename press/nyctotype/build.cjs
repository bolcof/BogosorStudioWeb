const fs = require('node:fs/promises');
const path = require('node:path');
const sharp = require('sharp');
const JSZip = require('jszip');
const { Download } = require('lucide');
const root = path.resolve(__dirname, '../..');
const out = path.join(root, 'docs/presskits/NyctoType');
const esc = value => String(value).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const bi = (value, tag = 'span', attrs = '') => `<${tag} data-ja="${esc(value.ja)}" data-en="${esc(value.en)}"${attrs}>${esc(value.ja)}</${tag}>`;
const icon = `<svg aria-hidden="true" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${Download.map(([tag,attrs])=>`<${tag} ${Object.entries(attrs).map(([key,value])=>`${key}="${esc(value)}"`).join(' ')}/>`).join('')}</svg>`;

async function build() {
  const data = JSON.parse(await fs.readFile(path.join(__dirname, 'content.json'), 'utf8'));
  const assets = JSON.parse(await fs.readFile(path.join(__dirname, 'assets.json'), 'utf8'));
  const labels = data.labels;
  const zips = {ja:new JSZip(), en:new JSZip()};
  const zipRoots = {ja:'NyctoType-PressKit-JA', en:'NyctoType-PressKit-EN'};
  const zipOptions = {date: new Date(`${data.updated}T00:00:00Z`), createFolders: false};
  const addZip = (lang, name, bytes) => zips[lang].file(`${zipRoots[lang]}/${name}`, bytes, zipOptions);
  await fs.rm(path.join(out, 'previews'), {recursive:true, force:true});
  await fs.mkdir(path.join(out, 'previews'), {recursive:true});
  await fs.mkdir(path.join(out, 'downloads'), {recursive:true});
  for (const asset of assets) {
    const original = await fs.readFile(path.join(out, 'assets', asset.file));
    const info = await sharp(original).metadata();
    Object.assign(asset, {width:info.width, height:info.height, bytes:original.length});
    asset.preview = `previews/${path.basename(asset.file, '.png')}.webp`;
    await sharp(original).resize({width:1200, withoutEnlargement:true}).webp({quality:85}).toFile(path.join(out, asset.preview));
    if (asset.kind !== 'screenshot' || asset.file.endsWith('_JP.png')) addZip('ja', asset.file, original);
    if (asset.kind !== 'screenshot' || asset.file.endsWith('_ENG.png')) addZip('en', asset.file, original);
  }
  for (const lang of ['ja','en']) {
    const t = value => value[lang];
    const languageAssets = assets.filter(asset=>asset.kind!=='screenshot' || asset.file.endsWith(lang==='ja' ? '_JP.png' : '_ENG.png'));
    const parts = ['NyctoType / BogosorGames', `${t(labels.updated)}: ${data.updated}`, '', t(data.tagline), '', t(data.short), '', t(labels.vision), t(data.vision), '', t(labels.facts), ...data.facts.map(f=>`${t(f.label)}: ${t(f.value)}`), `Steam: ${data.steam}`, `${t(labels.site)}: ${data.website}`, `Contact: ${data.email}`, '', t(labels.rules), t(data.rulesSummary), '', t(labels.features), ...data.features.flatMap(f=>[t(f.title),t(f.text),'']), t(labels.planned), t(data.planned), '', t(labels.screenshots), t(data.zipImageNote), ...languageAssets.map(a=>`${a.file} - ${t(a.caption)} (${a.width} x ${a.height})`), '', t(labels.usage), ...data.usage.map(t), '', t(labels.contact), t(data.contactText), data.email, ''];
    const text = parts.join('\n');
    const filename = `NyctoType-PressKit-${lang}.txt`;
    await fs.writeFile(path.join(out, 'downloads', filename), text);
    addZip(lang, filename, text);
  }
  await fs.rm(path.join(out, 'downloads/NyctoType-PressKit.zip'), {force:true});
  const archives = {};
  for (const lang of ['ja','en']) {
    archives[lang] = await zips[lang].generateAsync({type:'nodebuffer',compression:'DEFLATE',compressionOptions:{level:6}});
    await fs.writeFile(path.join(out, `downloads/${zipRoots[lang]}.zip`), archives[lang]);
  }
  const download = lang => `<a class="press-download primary" href="downloads/${zipRoots[lang]}.zip" download>${icon}${bi(labels[lang === 'ja' ? 'zipJa' : 'zipEn'])}<small>${(archives[lang].length/1048576).toFixed(1)} MB</small></a>`;
  const downloads = `<div class="press-zip-downloads">${download('ja')}${download('en')}</div>`;
  const assetHtml = asset => {
    const assetLanguage = asset.kind !== 'screenshot' ? 'all' : asset.file.endsWith('_JP.png') ? 'ja' : 'en';
    const note = asset.note ? bi(asset.note,'p',' class="asset-meta asset-note"') : '';
    return `<figure class="press-asset ${asset.kind}" data-asset-language="${assetLanguage}"><a class="asset-preview" href="assets/${asset.file}" target="_blank" rel="noopener" aria-label="${esc(asset.caption.ja)}" data-alt-ja="${esc(asset.caption.ja)}" data-alt-en="${esc(asset.caption.en)}"><img src="${asset.preview}" alt="${esc(asset.caption.ja)}" data-alt-ja="${esc(asset.caption.ja)}" data-alt-en="${esc(asset.caption.en)}" width="${asset.width}" height="${asset.height}" loading="lazy"></a><figcaption>${bi(asset.caption,'h3')}<p class="asset-meta">${asset.width} × ${asset.height} · PNG · ${(asset.bytes/1048576).toFixed(1)} MB</p>${note}<a class="asset-download" href="assets/${asset.file}" download>${icon}${bi(labels.original)}</a></figcaption></figure>`;
  };
  const section = (id, body) => `<section class="press-section" id="${id}">${bi(labels[id],'h2')}${body}</section>`;
  const html = `<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="${esc(data.short.ja)}" data-meta-ja="${esc(data.short.ja)}" data-meta-en="${esc(data.short.en)}">
  <meta name="robots" content="noindex, nofollow">
  <meta property="og:title" content="NyctoType Press Kit | BogosorGames">
  <meta property="og:image" content="previews/NyctoType-cover-image.webp">
  <title>NyctoType Press Kit | BogosorGames</title>
  <link rel="icon" href="../../favicon.ico" sizes="any">
  <link rel="stylesheet" href="../../games/game-page.css">
  <link rel="stylesheet" href="presskit.css">
  <script src="presskit.js" defer></script>
</head>
<body class="presskit">
  <a class="press-skip" href="#about">${bi({ja:'本文へ',en:'Skip to content'})}</a>
  <header class="topbar"><div class="wrap topbar-inner"><a class="brand" href="../../index.html">BogosorStudio</a><div class="press-language" role="group" aria-label="Language"><button type="button" data-language="ja" aria-pressed="true" lang="ja">日本語</button><button type="button" data-language="en" aria-pressed="false" lang="en">English</button></div></div></header>
  <main>
    <header class="press-heading wrap"><p class="press-eyebrow">BOGOSORGAMES / ${bi(labels.press)}</p><h1>NyctoType</h1>${bi(data.tagline,'p',' class="press-tagline"')}<div class="press-actions">${downloads}<a class="press-text-link" href="${data.steam}" target="_blank" rel="noopener">Steam ↗</a></div><p class="press-date">${bi(labels.updated)} <time datetime="${data.updated}">${data.updated}</time></p></header>
    <nav class="press-nav wrap" aria-label="${esc(labels.press.ja)}">${['about','screenshots','artwork','downloads','usage','contact'].map(id=>`<a href="#${id}">${bi(labels[id])}</a>`).join('')}</nav>
    <div class="wrap press-layout">
      <aside class="press-facts" id="facts">${bi(labels.facts,'h2')}<dl>${data.facts.map(f=>`<div>${bi(f.label,'dt')}${bi(f.value,'dd')}</div>`).join('')}<div><dt>Steam</dt><dd><a href="${data.steam}" target="_blank" rel="noopener">NyctoType ↗</a></dd></div><div>${bi(labels.site,'dt')}<dd><a href="${data.website}" target="_blank" rel="noopener">NyctoType / BogosorGames ↗</a></dd></div><div>${bi(labels.contact,'dt')}<dd>${data.email}</dd></div></dl></aside>
      <div class="press-main">
        ${section('about',bi(data.short,'p') + `<div class="press-vision">${bi(labels.vision,'h3')}${bi(data.vision,'p')}</div>` + bi(labels.rules,'h3') + bi(data.rulesSummary,'p') + bi(labels.features,'h3') + data.features.map(f=>`<div class="press-feature">${bi(f.title,'h4')}${bi(f.text,'p')}</div>`).join('') + `<div class="press-planned">${bi(labels.planned,'h3')}${bi(data.planned,'p')}</div>`)}
        ${section('screenshots',bi(data.imageNote,'p',' class="press-muted"')+`<div class="press-assets">${assets.filter(a=>a.kind==='screenshot').map(assetHtml).join('')}</div>`)}
        ${section('artwork',`<div class="press-assets art-assets">${assets.filter(a=>a.kind!=='screenshot').map(assetHtml).join('')}</div>`)}
        ${section('downloads',bi(data.downloadNote,'p')+downloads+`<div class="press-texts"><a href="downloads/NyctoType-PressKit-ja.txt" download>${icon}日本語 TXT</a><a href="downloads/NyctoType-PressKit-en.txt" download>${icon}English TXT</a></div>`)}
        ${section('usage',data.usage.map(p=>bi(p,'p')).join('')+`<p class="press-credit">NyctoType / BogosorGames<br><a href="${data.steam}">${data.steam}</a></p>`)}
        ${section('contact',bi(data.contactText,'p')+`<p><strong>BogosorGames</strong><br>${data.email}</p><div class="press-texts"><a href="${data.website}">${bi(labels.site)} ↗</a><a href="${data.steam}">Steam ↗</a></div>`)}
      </div>
    </div>
  </main>
  <footer class="wrap press-footer"><span>NyctoType / BogosorGames</span><a href="#about">${bi({ja:'ゲーム紹介へ戻る',en:'Back to the game overview'})} ↑</a></footer>
</body>
</html>`;
  await fs.writeFile(path.join(out, 'index.html'), html);
  for (const name of ['presskit.css','presskit.js']) await fs.copyFile(path.join(__dirname,name),path.join(out,name));
  console.log(`Generated bilingual HTML, ${assets.length} previews, 2 TXT files and 2 ZIPs (JA ${(archives.ja.length/1048576).toFixed(1)} MB / EN ${(archives.en.length/1048576).toFixed(1)} MB; ${Object.keys(zips.ja.files).length} files each).`);
}
build().catch(error=>{console.error(error);process.exitCode=1;});
