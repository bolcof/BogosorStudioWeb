import json
from base64 import b64encode
import re
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class VisibleText(HTMLParser):
    def __init__(self):
        super().__init__()
        self.parts = []
        self.hidden = False
        self.chapter = None
        self.chapters = {}
        self.current_link = None
        self.linked_images = []
        self.videos = []
        self.links = []

    def handle_starttag(self, tag, attrs):
        attributes = dict(attrs)
        if tag == 'a':
            self.current_link = attributes.get('href')
            self.links.append((self.chapter, self.current_link))
        if tag == 'iframe':
            self.videos.append((self.chapter, attributes))
        if tag == 'img' and self.current_link:
            self.linked_images.append((attributes.get('alt'), self.current_link))
        if tag == 'section':
            self.chapter = dict(attrs).get('data-chapter')
            if self.chapter:
                self.chapters[self.chapter] = []
        if tag in ('style', 'script'):
            self.hidden = True

    def handle_endtag(self, tag):
        if tag == 'a':
            self.current_link = None
        if tag == 'section':
            self.chapter = None
        if tag in ('style', 'script'):
            self.hidden = False

    def handle_data(self, data):
        if not self.hidden:
            self.parts.append(data)
            if self.chapter:
                self.chapters[self.chapter].append(data)


def normalized(text):
    return re.sub(r'\s+', '', text)


parser = VisibleText()
parser.feed((ROOT / 'output/html/NyctoType-Pitch.html').read_text())
visible = normalized(''.join(parser.parts))
for removed in (
    'コマの獲得・強化、ボス戦、物語の展開は製品版に向けた開発予定を含みます。',
    'ランクシステムは開発予定です。ラウンド間の強化を含む3ラウンド制は検討中です。',
    '取得したSteamDBページにはキャッシュを含みます。',
    'デバイス協業の検討用イメージ。',
    '元のFigma',
):
    assert normalized(removed) not in visible
for restored in (
    '配信市場の参考事例です。本作の配信実績・出演予定・提携を示すものではありません。',
):
    assert normalized(restored) in visible
markup = (ROOT / 'output/html/NyctoType-Pitch.html').read_text()
for chapter, filename in (('rules', 'gameplay-current.png'), ('screen', 'console-current.png'), ('solo', 'story-dialogue.png')):
    section = markup.split(f'id="{chapter}"', 1)[1].split('</section>', 1)[0]
    encoded = b64encode((ROOT / 'public/images' / filename).read_bytes()).decode('ascii')
    assert f'src="data:image/png;base64,{encoded}"' in section
for slot_id in ('01', '02', '03', '13', '14', '15', '16'):
    slot_markup = markup.split(f'data-slot="{slot_id}"', 1)[1].split('</figure>', 1)[0]
    assert 'class="slot-image"' in slot_markup
    assert 'src="data:image/png;base64,' in slot_markup
    assert 'class="placeholder"' not in slot_markup
gamescom_slot = markup.split('data-slot="07"', 1)[1].split('</figure>', 1)[0]
gamescom_image = b64encode((ROOT / 'public/images/07-gamescom.jpg').read_bytes()).decode('ascii')
assert f'src="data:image/jpeg;base64,{gamescom_image}"' in gamescom_slot
assert 'gamescom 2026のNyctoType展示風景' in gamescom_slot
assert 'NyctoType / gamescom 2026 展示風景' in gamescom_slot
assert 'ローグライトのマップ（イメージ画像）' in visible
device_slot = markup.split('data-slot="12"', 1)[1].split('</figure>', 1)[0]
device_section = markup.split('id="devices"', 1)[1].split('</section>', 1)[0]
assert 'class="device-layout"' in device_section
assert device_section.index('data-source-id="2611:216"') < device_section.index('data-slot="12"')
device_image = b64encode((ROOT / 'public/images/12-keyboard.jpg').read_bytes()).decode('ascii')
assert f'src="data:image/jpeg;base64,{device_image}"' in device_slot
assert '台北ゲームショウ2026で使用した提供機材' in device_slot
assert 'class="placeholder"' not in markup
assert 'NyctoType / 台北ゲームショウ2026' not in gamescom_slot
assert not any('figma.com' in href for _, href in parser.links if href)
source = json.loads((ROOT / 'app/original-deck.json').read_text())
corrected = {'2611:56', '2611:97', '2611:109', '2611:113', '2611:416', '2611:421', '2611:582', '2611:579', '2611:140', '2611:143', '2611:192', '2611:593', '2611:171', '2611:216', '2611:249', '2611:250'}
excluded = {
    **{f'2611:{i}': 'Old schedule replaced with current roadmap at user request' for i in (301, 302, 303, 304, 308, 309, 310, 316, 317, 318, 324, 325, 326, 332, 333, 334)},
    '2611:225': 'Keyboard market chapter removed at user request',
    '2611:229': 'Keyboard market chapter removed at user request',
    '2611:123': 'Competitive play and spectator appeal merged into esports chapter at user request',
    '2611:594': 'Active skills merged into screen chapter with user-approved copy',
    '2611:218': 'ICT education page removed at user request',
    '2611:70': 'Personal profile replaced with team background at user request',
    '2611:71': 'Personal profile replaced with team background at user request',
    '2611:72': 'Individual awards removed at user request',
    '2611:80': 'Personal profile replaced with team background at user request',
    '2611:81': 'Outsourcing paragraph: previously requested removal',
    '2611:127': 'Duplicate market paragraph: retain 2611:140 instead',
}
checked = []
missing = []
for slide in source:
    for entry in slide['text']:
        if entry['id'] == '2611:49':
            for line in entry['text'].strip().splitlines():
                label, value = re.split(r'[:：]', line, maxsplit=1)
                if label.strip() == '運営形態':
                    value = '販売・課金コンテンツ'
                assert normalized(label + value) in visible, f'Missing cover fact: {line}'
            checked.append(entry['id'])
            continue
        if len(entry['text']) < 70 or entry['id'] in corrected or entry['id'] in excluded:
            continue
        checked.append(entry['id'])
        if normalized(entry['text']) not in visible:
            missing.append(entry['id'])
assert not missing, f'Missing unchanged original paragraphs: {missing}'
streaming_copy = normalized(''.join(parser.chapters['streaming']))
market_copy = normalized(''.join(parser.chapters['market']))
for expected in ('取り上げられる可能性を高めようと考えています。', '飽きの来ない体験を作ることを狙っています。', 'プレイヤー層を広げることを目指しています。', '認知拡大とコミュニティ形成につなげたいと考えています。', '技術の高さを簡単に伝えることができます。'):
    assert normalized(expected) in streaming_copy
assert '成長への意欲につなげることを狙っています。' in market_copy
assert '他ゲームに比べて非常に低いという点で強みがあります。' in market_copy
for chapter, expected in (
    ('tournament', '実施時期・配布するビルド・開催形式は、パートナーと相談して決めさせていただければと思います。'),
    ('devices', '具体的な内容や実現方法は、企業の皆様とご相談させていただければと思います。'),
    ('event-plan', 'パートナーとご相談のうえ、一緒に検討させていただければと思います。'),
    ('partnership', 'ご対応いただける範囲に応じて内容や役割分担をご相談できればと考えています。'),
):
    assert normalized(expected) in normalized(''.join(parser.chapters[chapter]))
for obsolete in ('パートナーと相談して決めます。', 'パートナーと設計します。', '協力先と相談して決定。', '相談させてください。'):
    assert normalized(obsolete) not in visible
device_copy = normalized(''.join(parser.chapters['devices']))
assert 'EPOMAKER・LINSOUL' in device_copy
assert '協業先は未定' not in device_copy and '協業先・コラボ製品・協賛は未定' not in device_copy
assert '応募時の旧計画' not in visible
assert '元の企画案であり' not in visible and '元の企画書の計画です' not in visible
assert '速さと正確さを競うだけ' not in visible
for expected in ('キーボード全体の打ち心地や操作性が重要です。', 'ゲーム内のアイテムやビジュアルとしても扱える題材です。', 'デバイス企業との協業を積極的に進めていきたいと考えています。'):
    assert normalized(expected) in device_copy
for removed in ('その高スペックを使い切れていません', 'ブランディングによる分断', '大手の企業へ対抗したい', '市場についての記述は企画上の仮説です'):
    assert normalized(removed) not in device_copy
for expected in ('提示された文字列を入力', '相手側の端から盤外にコマを落とす', 'ランダムに現れる強化項目', '現代美術をバックグラウンドに'):
    assert normalized(expected) in visible
for obsolete in ('強いコマを召喚するためには長い課題', '6~8文字の単語を3個', '単語を３つ入力', 'GIGAスクール構想', 'ICT教育への応用'):
    assert normalized(obsolete) not in visible
for removed in ('読み合いの不確実さと、ゲーム内の乱数は別', '盤上の進行に乱数を用いない', '出題・ランダム要素を含む効果'):
    assert normalized(removed) not in visible
for added in ('対応予定言語', 'それぞれ別に設定できるようにする予定', '一部のみのご協力', '招待参加者の紹介', '賞金・賞品の提供', '展示会への出展', '国家AIに支えられた地下社会', 'ローグライト要素を含んだストーリーモード'):
    assert normalized(added) in visible
for revised in ('余地があると考えました', 'タイピング入力によるリソースで何を行うのかの選択を', '展示を経験してきました。', 'こうした制作活動で培った経験を、ゲームのコンセプトやメカニクスなど、体験の設計に活かして開発しています。', 'TGCA 第1期'):
    assert normalized(revised) in visible
for piece_detail in ('コマごとに「移動コスト」「生成コスト」「移動方向」「アビリティ」が異なります。', '「相手のコマを破壊する」「押し出す」「ダメージを増やす」', 'どのコマを出すかも重要な選択です。'):
    assert normalized(piece_detail) in visible
assert normalized('コマごとに、主に次の3つが異なります。') not in visible
for deck_detail in ('「今あるコマを動かすか、新しく生成するか」「どの方向から攻め、どこを守るか」', 'コマの強さや数に応じて、デッキ全体の入力コストも変わる設計を予定しています。', '課題の数ではなく、入力する文字列の長さに影響する'):
    assert normalized(deck_detail) in visible
assert normalized('与えるダメージが2倍となるコマ') not in visible
piece_copy = normalized(''.join(parser.chapters['pieces']))
ability_copy = normalized(''.join(parser.chapters['passive']))
assert 'active' not in parser.chapters
assert len(parser.chapters) == 23
assert 'comparisons' not in parser.chapters
assert 'roadmap' not in parser.chapters
schedule_copy = normalized(''.join(parser.chapters['schedule-original']))
for expected in ('2026年9月', '2026年12月', '2027年3月', '2027年7月', '2027年10月', '2027年12月', 'TGSへ出展', '配布可能なデモをSteamストアで公開', '対戦イベントに向けた準備', 'ローグライトの1周を完成', 'ソロの機能追加と並行して整備', '各年月は現時点での目標です'):
    assert normalized(expected) in schedule_copy
for removed in ('年月未定', '0.4.x', '正式版 1.0', 'Steam Demo', '正式版の発売時期は未定'):
    assert normalized(removed) not in schedule_copy
for expected in ('試遊を通じて本作をなるべく広く届ける', 'チュートリアルとCPU戦、オンライン対戦を遊べます', 'プリセットデッキ', 'TGCA支援期間終了に向け、デモを整える', 'デモに収録するローグライト1周分のストーリーを完成させ', '外部テスト期間'):
    assert normalized(expected) in schedule_copy
assert '2027年発売目標' not in visible
progress_copy = normalized(''.join(parser.chapters['progress']))
for expected in ('これまでの歩み', 'TGCA第1期に採択', '東京ゲームショウ2025', '台北ゲームショウ2026', 'PONOS財団', '東京ゲームダンジョン12', 'gamescom2026', 'DevilCatwith2cats'):
    assert expected in progress_copy
for removed in ('ウィッシュリスト', '610', '実装済みの基礎', 'GamerSky', '公式サイトの活動記録'):
    assert removed not in progress_copy
for href in ('https://www.youtube.com/watch?v=TqYJ9ct6jD0', 'https://www.taptap.cn/moment/843052528860923924', 'https://www.4gamer.net/games/991/G999110/20260905003/'):
    assert ('progress', href) in parser.links
progress_markup = (ROOT / 'output/html/NyctoType-Pitch.html').read_text().split('id="progress"', 1)[1].split('</section>', 1)[0]
coverage_markup = progress_markup.split('class="coverage-list"', 1)[1]
assert '<img' not in coverage_markup and '<iframe' not in coverage_markup
assert 'device-market' not in parser.chapters
assert 'キーボード市場への提案' not in visible
assert ('Epistory - Typing Chronicles', 'https://store.steampowered.com/app/398850/Epistory__Typing_Chronicles/') in parser.linked_images
assert ('Nanotale - Typing Chronicles', 'https://store.steampowered.com/app/944920/Nanotale__Typing_Chronicles/') in parser.linked_images
assert ('Glyphica: Typing Survival', 'https://store.steampowered.com/app/2400160/Glyphica_Typing_Survival/') in parser.linked_images
sales_markup = (ROOT / 'output/html/NyctoType-Pitch.html').read_text().split('id="sales-plan"', 1)[1].split('</section>', 1)[0]
for heading in ('販売価格', '販売目標本数', '売上（試算）'):
    assert f'<h3>{heading}</h3>' in sales_markup
for amount in ('2200円(14ドル)', '10万本', '2億2000万円'):
    assert amount in normalized(''.join(parser.chapters['sales-plan']))
assert sales_markup.count('class="sales-reference"') == 3
assert '<h3>販売目標の根拠・参考作品</h3>' in sales_markup
for title in ('Epistory - Typing Chronicles', 'Nanotale - Typing Chronicles', 'Glyphica: Typing Survival'):
    assert f'<h4>{title}</h4>' in sales_markup
assert '980円 × 約19.9万本 ≒ 2.0億円（概算）' in sales_markup
for estimate in ('1,480円 × 約37.6万本 ≒ 5.6億円（概算）', '2,050円 × 約2.7万本 ≒ 5,576万円（概算）', '中央値：VG Insights 約37.6万本', '中央値：Gamalytic 約2.7万本', '中央値：VG Insights 約19.9万本', '日本通常価格（セール割引前）'):
    assert estimate in sales_markup
for app_id in (398850, 944920, 2400160):
    assert ('sales-plan', f'https://steamdb.info/app/{app_id}/charts/') in parser.links
for owners, price, expected in (([291200, 375900, 1440000], 1480, 556332000), ([25900, 27200, 209700], 2050, 55760000), ([186000, 199400, 201500], 980, 195412000)):
    assert sorted(owners)[1] * price == expected
assert '36万本' not in sales_markup and '2.3万本' not in sales_markup
assert '所有者数と有料販売本数も一致するとは限りません。' in sales_markup
assert ('sales-plan', 'https://steamdb.info/app/2400160/charts/') in parser.links
schedule_markup = (ROOT / 'output/html/NyctoType-Pitch.html').read_text().split('id="schedule-original"', 1)[1].split('</section>', 1)[0]
assert schedule_markup.count('class="release-period"') == 6
assert len(re.findall(r'<li[^>]*><div class="release-period">', schedule_markup)) == 6
assert re.findall(r'data-stage="(\d)"', schedule_markup) == ['1', '2', '3', '4', '5', '6']
assert 'release-connection' not in schedule_markup
assert 'release-diagonal' not in schedule_markup
assert 'release-vertical' not in schedule_markup
assert schedule_markup.count('<h4>目的</h4>') == 6
assert schedule_markup.count('<h4>詳細</h4>') == 6
assert 'release-version' not in schedule_markup
assert '対応予定言語' in sales_markup
mode_copy = normalized(''.join(parser.chapters['current-modes']))
for expected in ('記憶を失ったプレイヤー', 'ラウンド間に強化を挟む形式', '1ラウンドで決着する対戦', 'フレンドとの対戦'):
    assert expected in mode_copy
for removed in ('元の企画案とは分けて', 'カジュアルマッチを軸に', '初回は小規模開催', 'まずは小規模な対戦イベント'):
    assert normalized(removed) not in visible
assert '交流戦を繰り返し' in normalized(''.join(parser.chapters['event-plan']))
contact_markup = (ROOT / 'output/html/NyctoType-Pitch.html').read_text().split('id="contact"', 1)[1].split('</section>', 1)[0]
assert '<p>SteamでNyctoTypeを見る</p>' not in contact_markup
assert ('contact', 'https://store.steampowered.com/app/3968600/NyctoType/') in parser.links
assert 'esports-context' not in parser.chapters
esports_copy = normalized(''.join(parser.chapters['esports']))
for expected in ('競技大会はすでに開催されています', '競技市場の広がりはまだ限られていると考えています', '不確実性', '打撃・投げの択', '上級者のパフォーマンスには見応えがある'):
    assert expected in esports_copy
assert '格闘ゲームの例は' not in esports_copy
assert '普及している例はありません' not in visible
assert (ROOT / 'output/html/NyctoType-Pitch.html').read_text().count('class="esports-triangle') == 4
screen_copy = normalized(''.join(parser.chapters['screen']))
for expected in ('同じくコンソールを使用して「アクティブスキル」を発動できるようにする予定です。', '発動のタイミングも重要です。', '相手が長くコマを動かしていない間は、コンソールで強力なコマやスキルを準備している可能性があるため、注意が必要です。'):
    assert expected in screen_copy
assert 'クールタイム' not in screen_copy
assert 'パッシブスキル' not in visible
for effect in ('「相手のコマを破壊する」', '「押し出す」', '「ダメージを増やす」'):
    assert effect not in piece_copy
    assert effect in ability_copy
assert 'アビリティは、コマに備わる特殊な効果です。' in ability_copy
assert '強化によってアビリティを追加できるようにする予定です。' in ability_copy
assert '同じ種類のコマでも、付いているアビリティによって' not in ability_copy
for game in json.loads((ROOT / 'app/artwork-references.json').read_text()):
    assert (game['title'] + 'のゲーム画面', game['href']) in parser.linked_images
artwork_copy = normalized(''.join(parser.chapters['artwork']))
world_copy = normalized(''.join(parser.chapters['world']))
solo_copy = normalized(''.join(parser.chapters['solo']))
versus_copy = normalized(''.join(parser.chapters['versus']))
for expected in ('デッキ構築による戦略に加え', '3ラウンド制にして、ラウンド間にランダム要素を含む強化を挟む構成も検討しています。', '大会も開催できるようなゲームを目指しています。'):
    assert expected in versus_copy
market_copy = normalized(''.join(parser.chapters['market']))
assert 'タイピング競技が持つ速さと正確さを競う魅力に、盤面上の駆け引きと視覚的な演出を加え' in market_copy
assert normalized('REALFORCE TYPING CHAMPIONSHIP 2023') in market_copy
assert 'YouTubeで見る' not in visible
expected_videos = [
    ('versus', '8GM8g_T3FFU', 'NyctoType 2026.09.09 Build CPUbattle'),
    ('market', 'zNrgd8MnGU4', 'REALFORCE TYPING CHAMPIONSHIP 2023 大会紹介 / 日テレスポーツ【公式】'),
    ('streaming', 'WTJljoK-qbE', '第2回 にじさんじ打鍵王 / 鈴木勝'),
    ('streaming', 'bMiIeThZcpY', 'ストリートファイター6：ボンちゃん vs ウメハラ / レッドブルプレイ'),
    ('tournament', 'zNrgd8MnGU4', 'REALFORCE TYPING CHAMPIONSHIP 2023 大会紹介 / 日テレスポーツ【公式】'),
    ('contact', '8GM8g_T3FFU', 'NyctoType 2026.09.09 Build CPUbattle'),
]
assert len(parser.videos) == len(expected_videos)
for (chapter, embed), (expected_chapter, video_id, title) in zip(parser.videos, expected_videos):
    assert chapter == expected_chapter
    assert embed['src'] == f'https://www.youtube-nocookie.com/embed/{video_id}'
    assert embed['title'] == title
    assert embed['loading'] == 'lazy'
    assert embed['referrerpolicy'] == 'strict-origin-when-cross-origin'
    assert (chapter, f'https://www.youtube.com/watch?v={video_id}') not in parser.links
assert not any('youtube.com' in href for _, href in parser.linked_images)
assert 'ホロライブタイピング最速王決定戦' not in visible
sales_points_markup = (ROOT / 'output/html/NyctoType-Pitch.html').read_text().split('id="sales-points"', 1)[1].split('</section>', 1)[0]
assert '<img' not in sales_points_markup
assert 'um4gLfGjp3E' not in (ROOT / 'output/html/NyctoType-Pitch.html').read_text()
for expected in ('各要素をどの段階で公開するかは、開発の進捗やプレイヤーの反応を見ながら調整します。', 'メディアアートの文脈を取り入れたステージやキャラクターたちとの出会いや対決', 'タイピング速度の向上や戦略の洗練、デッキのアップデートを武器に', 'プレイヤーのタイピング速度に合わせたレベルで開始でき'):
    assert expected in solo_copy
assert 'アート作品に触れるような' not in solo_copy
assert '初期版ではローグライトの戦闘を主軸' not in solo_copy
assert 'NyctoTypeのゲーム内世界' not in world_copy
assert '製品版に向けた構想です。物語の核心を含みます。' not in world_copy
assert world_copy.index('PCの中で戦うプログラム') < world_copy.index('ゴミ箱フォルダで目覚める主人公') < world_copy.index('国家AIに支えられた地下社会')
assert '互いにバグを送り合い、相手を破壊するために戦っています。' in world_copy
for expected in ('実際にボードゲームを遊ぶような直感的でわかりやすい体験を目指します。', '物理的なボードゲームではできない表現', 'ゲーム実況や大会の配信でも、頻繁にカメラを切り替えずに、戦況や各プレイヤーの狙いを追いやすくなります。'):
    assert expected in artwork_copy
assert '想像を超えたゲーム体験を提供します。' not in artwork_copy
print(json.dumps({'unchanged_original_blocks': len(checked), 'missing': missing, 'explicit_corrections': len(corrected), 'documented_exclusions': excluded}, ensure_ascii=False, indent=2))
