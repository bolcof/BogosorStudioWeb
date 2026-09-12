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
  const archive = await JSZip.loadAsync(await fs.readFile(path.join(out,'downloads/NyctoType-PressKit.zip')));
  const expected = [...assets.map(a=>a.file),'NyctoType-PressKit-ja.txt','NyctoType-PressKit-en.txt'].map(n=>`NyctoType-PressKit/${n}`).sort();
  assert.deepEqual(Object.keys(archive.files).sort(), expected);
  for (const asset of assets) {
    const original = await fs.readFile(path.join(out,'assets',asset.file));
    assert.deepEqual(await archive.file(`NyctoType-PressKit/${asset.file}`).async('nodebuffer'),original);
    if (!asset.source.includes('initial import')) assert.deepEqual(original,await fs.readFile(path.join(root,asset.source)));
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
    assert.equal(await archive.file(`NyctoType-PressKit/${filename}`).async('string'),text);
    for (const value of [data.short[lang],data.planned[lang],...data.usage.map(u=>u[lang])]) assert(text.includes(value));
    assert(!/TBD|youtube|youtu\.be|pitchdecks|国家AI|1億|2027年10月|2027年12月|TJ Shizzle/i.test(text));
  }
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
        assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
        assert.equal(await page.locator('img').evaluateAll(imgs=>imgs.every(img=>img.complete&&img.naturalWidth>0)),true);
        for (const id of ['about','screenshots','artwork','downloads','usage','contact']) {
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
    console.log('Passed: 9-file ZIP allowlist and byte equality, original assets and transparent logo, bilingual copy, desktop/mobile layouts, section links, 11 browser downloads, local links, and English direct entry.');
  } finally {
    if (browser) await browser.close();
    await new Promise(resolve=>server.close(resolve));
  }
}
check().catch(error=>{console.error(error);process.exitCode=1;});
