from pathlib import Path
import json,html,zipfile,shutil
R=Path(__file__).resolve().parents[2]; P=R/'docs/presskits/Reversi2048'; D=P/'downloads'; A=P/'assets'

for name in ['presskit.css','presskit.js']: shutil.copy2(Path(__file__).parent/name,P/name)
d=json.loads((Path(__file__).parent/'content.json').read_text()); B=lambda ja,en:{'ja':ja,'en':en}
def e(s): return html.escape(str(s),quote=True)
def bi(v,tag='span',attrs=''):return f'<{tag} data-ja="{e(v["ja"])}" data-en="{e(v["en"])}" {attrs}>{e(v["ja"])}</{tag}>'
def link(url,label,cls='press-download',download=False):return f'<a class="{cls}" href="{e(url)}" '+('download' if download else '')+'>'+bi(label)+'</a>'
def section(id,label,body):return f'<section class="press-section" id="{id}">'+bi(label,'h2')+body+'</section>'
labels={'about':B('ゲーム紹介','About'),'videos':B('動画・GIF','Video & GIF'),'screenshots':B('スクリーンショット','Screenshots'),'artwork':B('ロゴ・キーアート','Logo & Key Art'),'downloads':B('ダウンロード','Downloads'),'usage':B('素材利用について','Asset Use'),'contact':B('お問い合わせ','Contact')}
shots=d['screenshots']; files=['Reversi2048-KeyArt.png','Reversi2048-Logo.png']+[s['file'] for s in shots]
for file in files:
 if Path(file).name!=file or not (A/file).is_file(): raise ValueError('Missing or invalid asset: '+file)
for lang in ['ja','en']:
 t=lambda v:v[lang]
 facts='\n'.join(t(f['label'])+': '+t(f['value']) for f in d['facts'])
 body='\n\n'.join(['Reversi2048 / Bogosor Studio',t(d['tagline']),t(d['short']),facts,t(d['rules'])]+[t(f['title'])+'\n'+t(f['text']) for f in d['features']]+['Steam: '+d['steam'],'Demo: '+d['demo'],t(d['usage']),'Contact: '+d['email']]+([] if shots else [t(B('スクリーンショットは後日追加予定です。','Screenshots will be added later.'))]))
 (D/f'Reversi2048-PressKit-{lang}.txt').write_text(body+'\n')
 release='\n\n'.join([t(B('プレスリリース｜Steam体験版公開中','Press release | Steam demo available')),t(d['tagline']),t(B('Bogosor Studioは、ボードゲーム『Reversi2048』の体験版をSteamで公開しました。','Bogosor Studio has released a Steam demo for its board game Reversi2048.')),t(d['short']),t(d['rules']),'Steam demo: '+d['demo'],'Steam: '+d['steam'],'Contact: '+d['email']])
 (D/f'Reversi2048-Press-Release-{lang}.txt').write_text(release+'\n')
 with zipfile.ZipFile(D/f'Reversi2048-PressKit-{lang.upper()}.zip','w',zipfile.ZIP_DEFLATED) as z:
  for file in files:z.write(A/file,'Reversi2048/'+file)
  for name in [f'Reversi2048-PressKit-{lang}.txt',f'Reversi2048-Press-Release-{lang}.txt']:z.write(D/name,'Reversi2048/'+name)
downloads='<div class="press-zip-downloads">'+''.join(link(f'downloads/Reversi2048-PressKit-{lang.upper()}.zip',B(label+' 素材ZIP',label+' asset ZIP'),'press-download primary',True) for lang,label in [('ja','日本語'),('en','English')])+''.join(link(f'downloads/Reversi2048-Press-Release-{lang}.txt',B(label+' リリース TXT',label+' release TXT'),'press-download release',True) for lang,label in [('ja','日本語'),('en','English')])+'</div>'
def asset(file,caption):return '<figure class="press-asset"><a class="asset-preview" href="assets/'+e(file)+'"><img loading="lazy" src="assets/'+e(file)+'" alt="'+e(caption['ja'])+'" data-alt-ja="'+e(caption['ja'])+'" data-alt-en="'+e(caption['en'])+'"></a><figcaption>'+bi(caption,'h3')+link('assets/'+file,B('原寸PNGをダウンロード','Download original PNG'),'asset-download',True)+'</figcaption></figure>'
screens='<div class="press-assets">'+''.join(asset(s['file'],s['caption']) for s in shots)+'</div>' if shots else '<div class="shot-placeholder">'+bi(B('SCREENSHOTS / 準備中','SCREENSHOTS / Coming soon'),'strong')+bi(B('実際のゲーム画面は後日追加します。','Gameplay screenshots will be added here.'),'p')+'</div>'
facts='<dl>'+''.join('<div>'+bi(f['label'],'dt')+bi(f['value'],'dd')+'</div>' for f in d['facts'])+'</dl>'
features=''.join('<div class="press-feature">'+bi(f['title'],'h4')+bi(f['text'],'p')+'</div>' for f in d['features'])
head='<!doctype html><html lang="ja"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex"><title>Reversi2048 | Bogosor Studio</title><link rel="stylesheet" href="../../games/game-page.css"><link rel="stylesheet" href="presskit.css"><script defer src="presskit.js"></script><style>.shot-placeholder{border:1px dashed var(--line);padding:45px 24px;text-align:center;color:var(--muted)}.presskit{--gold:#f47b20}.press-section a{overflow-wrap:anywhere}.press-section>p,.press-feature p{white-space:pre-line}</style></head><body class="presskit">'
header='<a class="press-skip" href="#about">Skip to content</a><header class="topbar"><div class="wrap topbar-inner"><a class="brand" href="https://bolcof.github.io/BogosorStudioWeb/">BogosorStudio</a><div class="press-language" role="group" aria-label="Language"><button data-language="ja" aria-pressed="true">日本語</button><button data-language="en" aria-pressed="false">English</button></div></div></header>'
nav='<nav class="press-nav wrap" aria-label="プレスキット">'+''.join('<a href="#'+id+'">'+bi(label)+'</a>' for id,label in labels.items())+'</nav>'
contact=bi(B('取材・ゲーム紹介・素材についてのお問い合わせはこちら。','For coverage, interviews and asset inquiries, please contact us.'),'p')+'<a href="mailto:'+d['email']+'">'+d['email']+'</a>'
about=bi(d['short'],'p')+bi(B('基本ルール','How it plays'),'h3')+bi(d['rules'],'p')+features
mp4_size=(P/'media/Reversi2048-Title.mp4').stat().st_size/1048576
gif_size=(P/'media/Reversi2048-Title.gif').stat().st_size/1048576
video_body=bi(B('タイトル映像','Title video'),'h3')+'<video controls playsinline preload="metadata" style="display:block;width:100%;height:auto" aria-label="Reversi2048 title video"><source src="media/Reversi2048-Title.mp4" type="video/mp4"></video>'+bi(B('MP4は元動画のまま収録しています。GIFは冒頭4秒を960×540・30fpsに変換したループ版です（音声なし）。','The MP4 is the original, unmodified video. The GIF loops the first 4 seconds at 960×540 and 30 fps, without audio.'),'p')+'<div class="press-texts">'+link('media/Reversi2048-Title.mp4',B(f'元動画 MP4をダウンロード（{mp4_size:.1f} MB）',f'Download original MP4 ({mp4_size:.1f} MB)'),'asset-download',True)+link('media/Reversi2048-Title.gif',B(f'GIFをダウンロード（{gif_size:.1f} MB）',f'Download GIF ({gif_size:.1f} MB)'),'asset-download',True)+'</div><details><summary>'+bi(B('GIFプレビューを開く','Show GIF preview'))+'</summary><img loading="lazy" width="960" height="540" src="media/Reversi2048-Title.gif" alt="Reversi2048 title animation"></details>'+bi(B('動画とGIFは上記リンクから個別にダウンロードできます。素材ZIPには含めていません。','Download the video and GIF separately using the links above. They are not included in the asset ZIPs.'),'p','class="press-muted"')

press=head+header+'<main><header class="press-heading wrap"><p class="press-eyebrow">BOGOSOR STUDIO / PRESS KIT</p><h1>Reversi2048</h1>'+bi(d['tagline'],'p','class="press-tagline"')+downloads+'<p class="press-date">2026.10.20</p></header>'+nav+'<div class="wrap press-layout"><aside class="press-facts">'+bi(B('基本情報','Factsheet'),'h2')+facts+link(d['demo'],B('Steam体験版 ↗','Steam demo ↗'),'asset-download')+'</aside><div class="press-main">'+section('about',labels['about'],about)+section('videos',labels['videos'],video_body)+section('screenshots',labels['screenshots'],screens)+section('artwork',labels['artwork'],'<div class="press-assets">'+asset(files[0],B('キーアート','Key art'))+asset(files[1],B('ロゴ','Logo'))+'</div>')+section('downloads',labels['downloads'],bi(B('原寸スクリーンショット・ロゴ・キーアートと紹介文を収録しています。','Includes original screenshots, logo, key art and text.'),'p')+downloads)+section('usage',labels['usage'],bi(d['usage'],'p'))+section('contact',labels['contact'],contact)+'</div></div></main><footer class="wrap press-footer">Reversi2048 / Bogosor Studio <a href="../../games/Reversi2048.html">'+bi(B('ゲーム紹介ページへ','Game page'))+'</a></footer></body></html>'
(P/'index.html').write_text(press)
print('Built Reversi2048 press kit, releases and ZIPs.')
