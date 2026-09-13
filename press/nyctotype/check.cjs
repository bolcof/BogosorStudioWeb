const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const path = require('node:path');
const http = require('node:http');
const { chromium } = require('playwright');
const JSZip = require('jszip');
const sharp = require('sharp');
const root = path.resolve(__dirname, '../..');
const docs = path.join(root, 'docs');
const out = path.join(docs, 'presskits/NyctoType');

async function check() {
  const assets = JSON.parse(await fs.readFile(path.join(__dirname,'assets.json')));
  const data = JSON.parse(await fs.readFile(path.join(__dirname,'content.json')));
  const archives = {};
  const expected = {};
  for (const lang of ['ja','en']) {
    const code = lang.toUpperCase();
    archives[lang] = await JSZip.loadAsync(await fs.readFile(path.join(out,`downloads/NyctoType-PressKit-${code}.zip`)));
    const selected = assets.filter(asset=>asset.kind!=='screenshot' || asset.file.endsWith(lang==='ja' ? '_JP.png' : '_ENG.png'));
    expected[lang] = [...selected.map(a=>a.file),`NyctoType-PressKit-${lang}.txt`].map(n=>`NyctoType-PressKit-${code}/${n}`).sort();
    assert.deepEqual(Object.keys(archives[lang].files).sort(), expected[lang]);
  }
  for (const asset of assets) {
    const original = await fs.readFile(path.join(out,'assets',asset.file));
    const langs = asset.kind!=='screenshot' ? ['ja','en'] : [asset.file.endsWith('_JP.png') ? 'ja' : 'en'];
    for (const lang of langs) assert.deepEqual(await archives[lang].file(`${lang==='ja'?'NyctoType-PressKit-JA':'NyctoType-PressKit-EN'}/${asset.file}`).async('nodebuffer'),original);
    if (!asset.source.includes('initial import') && !asset.source.startsWith('User supplied')) assert.deepEqual(original,await fs.readFile(path.join(root,asset.source)));
    if (asset.kind==='logo') {
      const metadata = await sharp(original).metadata();
      assert.equal(metadata.hasAlpha,true);
      assert.equal(metadata.width,5000);
      assert.equal(metadata.height,2387);
      assert.equal((await sharp(original).stats()).isOpaque,false);
    }
  }
  for (const lang of ['ja','en']) {
    const filename = `NyctoType-PressKit-${lang}.txt`;
    const text = await fs.readFile(path.join(out,'downloads',filename),'utf8');
    assert.equal(await archives[lang].file(`${lang==='ja'?'NyctoType-PressKit-JA':'NyctoType-PressKit-EN'}/${filename}`).async('string'),text);
    assert(text.includes(data.zipImageNote[lang]));
    assert(!text.includes(lang==='ja' ? '_ENG.png' : '_JP.png'));
    for (const value of [data.short[lang],data.vision[lang],data.planned[lang],...data.latest.flatMap(item=>[item.title[lang],item.text[lang]]),...data.usage.map(u=>u[lang])]) assert(text.includes(value));
    assert(!/TBD|youtube|youtu\.be|pitchdecks|国家AI|1億|2027年10月|2027年12月|TJ Shizzle/i.test(text));
  }
  const pressReleaseFilename = 'NyctoType-Press-Release-2026-09-14.txt';
  const pressRelease = await fs.readFile(path.join(out,'downloads',pressReleaseFilename),'utf8');
  assert.equal(pressRelease,await fs.readFile(path.join(__dirname,'press-release-2026-09-14-ja.txt'),'utf8'));
  for (const value of ['2026年9月14日','2026年9月17日（木）～21日（月・祝）','東京ゲームショウ2026','ホール10／10-E17','一般向け体験版を2026年9月下旬にSteamで公開予定','TGCA（Top Game Creators Academy）第1期助成プロジェクト','BogosorGames',data.steam,data.website,data.email]) assert(pressRelease.includes(value));
  assert(!/TBD|youtube|youtu\.be|pitchdecks|国家AI|1億|2027年10月|2027年12月|TJ Shizzle/i.test(pressRelease));
  const pressEmail = await fs.readFile(path.join(__dirname,'press-email-2026-09-14-ja.txt'),'utf8');
  for (const value of ['【プレスリリース／TGS2026出展】','2026年9月17日（木）から21日（月・祝）','本件の情報は、受信後すぐにご掲載いただけます。',pressReleaseFilename,data.steam,data.website,data.email]) assert(pressEmail.includes(value));
  assert(!/\[at\]|TBD|youtube|youtu\.be/i.test(pressEmail));
  const types = {'.html':'text/html; charset=utf-8','.css':'text/css','.js':'text/javascript','.png':'image/png','.webp':'image/webp','.txt':'text/plain; charset=utf-8','.zip':'application/zip','.ico':'image/x-icon'};
  const server = http.createServer(async (request,response)=>{
    try {
      const url = new URL(request.url,'http://localhost');
      const filename = path.resolve(docs,`.${decodeURIComponent(url.pathname)}`);
      if (!filename.startsWith(docs+path.sep)) throw new Error('outside docs');
      const bytes = await fs.readFile(filename);
      response.writeHead(200,{'Content-Type':types[path.extname(filename)] || 'application/octet-stream'});
      response.end(bytes);
    } catch { response.writeHead(404); response.end(); }
  });
  await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
  let browser;
  try {
    browser = await chromium.launch({headless:true,channel:'chrome'});
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror',e=>errors.push(e.message));
    page.on('response',r=>{if(r.status()>=400)errors.push(`${r.status()} ${r.url()}`);});
    const url = `http://127.0.0.1:${server.address().port}/presskits/NyctoType/index.html`;
    await page.goto(url);
    await page.locator('img').evaluateAll(async imgs=>{ for(const img of imgs) img.loading='eager'; await Promise.all(imgs.map(img=>img.decode())); });
    await page.emulateMedia({reducedMotion:'reduce'});
    await fs.mkdir(path.join(__dirname,'verification'),{recursive:true});
    for (const width of [1440,390,320]) {
      await page.setViewportSize({width,height:900});
      for (const lang of ['en','ja']) {
        await page.locator(`[data-language="${lang}"]`).click();
        assert.equal(await page.locator('html').getAttribute('lang'),lang);
        assert.equal(await page.locator(`[data-language="${lang}"]`).getAttribute('aria-pressed'),'true');
        assert.equal(await page.locator('[data-ja][data-en]').evaluateAll((els,lang)=>els.every(el=>el.textContent===el.dataset[lang]),lang),true);
        assert.equal(await page.locator(`#screenshots .press-asset[data-asset-language="${lang}"]:visible`).count(),6);
        assert.equal(await page.locator(`#screenshots .press-asset[data-asset-language="${lang==='ja'?'en':'ja'}"]:visible`).count(),0);
        assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
        assert.equal(await page.locator('img').evaluateAll(imgs=>imgs.every(img=>img.complete&&img.naturalWidth>0)),true);
        for (const id of ['latest','about','screenshots','artwork','downloads','usage','contact']) {
          await page.locator(`.press-nav a[href="#${id}"]`).click();
          assert.equal(new URL(page.url()).hash,`#${id}`);
          const rect = await page.locator(`#${id} h2`).boundingBox();
          assert(rect.y>=64 && rect.y<900,`${width}/${lang}/${id} heading offscreen`);
        }
        await page.evaluate(()=>scrollTo(0,0));
        if(width!==320) await page.screenshot({path:path.join(__dirname,`verification/${width}-${lang}.png`),fullPage:true});
      }
    }
    const downloads = page.locator('a[download]');
    for (let i=0;i<await downloads.count();i++) {
      const link = downloads.nth(i);
      const assetLanguage = await link.evaluate(element=>element.closest('[data-asset-language]')?.dataset.assetLanguage);
      if (assetLanguage === 'ja' || assetLanguage === 'en') await page.locator(`[data-language="${assetLanguage}"]`).click();
      const href = await link.getAttribute('href');
      console.log(`Checking download: ${href}`);
      const [download] = await Promise.all([page.waitForEvent('download'),link.click()]);
      assert.equal(await download.failure(),null);
      assert.deepEqual(await fs.readFile(await download.path()), await fs.readFile(path.join(out,href)));
      // Space user gestures to avoid Chrome's rapid-download protection.
      await page.waitForTimeout(1100);
    }
    const hrefs = await page.locator('a[href]').evaluateAll(links=>links.map(a=>a.getAttribute('href')));
    for (const href of hrefs) {
      if(href.startsWith('#')) assert.equal(await page.locator(href).count(),1);
      else if(!/^(https:|mailto:)/.test(href)) await fs.access(path.resolve(out,href));
    }
    await page.goto(url+'?lang=en');
    assert.equal(await page.locator('html').getAttribute('lang'),'en');
    assert.equal(await page.locator('iframe,video').count(),0);
    assert.deepEqual(errors,[]);
    console.log(`Passed: two ${expected.ja.length}-file language-specific ZIP allowlists and byte equality, standalone press release TXT, original assets and transparent logo, bilingual copy, desktop/mobile layouts, section links, ${await downloads.count()} browser downloads, local links, and English direct entry.`);
  } finally {
    if (browser) await browser.close();
    await new Promise(resolve=>server.close(resolve));
  }
}
check().catch(error=>{console.error(error);process.exitCode=1;});
