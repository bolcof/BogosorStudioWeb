import { ArrowDown, ArrowUpRight, Image as ImageIcon } from 'lucide-react';
import { PrintButton } from './print-button';
import { UpdateHistory } from './update-history';
import original from './original-deck.json';
import previous from './deck-data.json';
import { imageSlots, type SlotKey } from './image-slots';
import artworkReferences from './artwork-references.json';
import englishCopy from './english-copy.json';
import { EsportsSection } from './esports-section';
import { ScheduleSection } from './schedule-section';
import { ProgressSection } from './progress-section';

const steam = 'https://store.steampowered.com/app/3968600/NyctoType/';
const email = 'electro.peaceful.oooo@gmail.com';

const sourceText = new Map(original.flatMap(slide => slide.text.map(entry => [entry.id, entry.text] as const)));
const coverFacts = sourceText.get('2611:49')!.trim().split(/\r?\n/).map(line => {
  const field = line.match(/^([^:：]+)[:：]\s*(.*)$/);
  if (!field) throw new Error(`Invalid cover fact: ${line}`);
  return { label: field[1].trim(), value: field[1].trim() === '運営形態' ? '販売・課金コンテンツ' : field[2].trim() };
});
const isAudienceFact = (label: string) => label === 'メインターゲット層' || label === 'サブ';

// Keep the source snapshot intact; only approved corrections live here.
const corrections: Record<string, string> = {
  '2611:143': sourceText.get('2611:143')!.replace('示すことができるため、成長への意欲も沸きやすいです。', '示し、成長への意欲につなげることを狙っています。'),
  '2611:192': sourceText.get('2611:192')!
    .replace('取り上げられる可能性が高まります。', '取り上げられる可能性を高めようと考えています。')
    .replace('飽きの来ない体験を作ることができます。', '飽きの来ない体験を作ることを狙っています。')
    .replace('視聴者は「自分も挑戦してみたい」という興味を抱き、プレイヤー層が広がります。', '視聴者に「自分も挑戦してみたい」という興味を持ってもらい、プレイヤー層を広げることを目指しています。')
    .replace('広い層への認知拡大とコミュニティ形成が期待できるのがこの形式の強みです。', '広い層への認知拡大とコミュニティ形成につなげたいと考えています。'),
  '2611:249': '1,480円 × 約37.6万本 ≒ 5.6億円（概算）',
  '2611:250': '2,050円 × 約2.7万本 ≒ 5,576万円（概算）',
  '2611:216': 'NyctoTypeでは、タイピングによってコマの操作やスキルの発動を行うため、キーボードがプレイ体験の中心となります。FPSの移動操作などで使う一部のキーだけでなく、キーボードの広い範囲を使うため、キーボード全体の打ち心地や操作性が重要です。\n\nまた、キーボードは現実の入力機器としてだけでなく、ゲーム内のアイテムやビジュアルとしても扱える題材です。実際の製品をゲーム内に登場させるなど、プレイ体験と結びついたコラボレーションにも価値があると考えています。\n\n製品を使った試遊会や大会、コラボキーボードの制作なども含め、デバイス企業との協業を積極的に進めていきたいと考えています。具体的な内容や実現方法は、企業の皆様とご相談させていただければと思います。',
  '2611:109': 'インターネットを介して他のプレイヤーと戦う、1vs1のリアルタイム対戦モードです。デッキ構築による戦略に加え、入力やタイプミス、スキルの発動が勝敗を左右するミリ秒単位の攻防が、観戦者にも緊張感を生みます。\n\n3ラウンド制にして、ラウンド間にランダム要素を含む強化を挟む構成も検討しています。試合中にデッキや戦い方が変化することで、逆転のチャンスを作ります。\n\nさらに、ランクシステムを導入してプレイヤーの実力を可視化。勝ち上がるにつれて、自分の実力に合った、手に汗握るハイレベルな対戦が楽しめるようにします。\n\n競技性の高いゲームプレイを求めるプレイヤーと観戦者の両方が楽しめ、大会も開催できるようなゲームを目指しています。',
  '2611:113': '全てを忘れたプレイヤーが、戦いを通じて少しずつ記憶を取り戻し、自分自身の行動を選択していく1人用モード。 メディアアートの文脈を取り入れたステージやキャラクターたちとの出会いや対決が待ち受けています。\n\nNPCだからこそ可能な理不尽かつ独創的なステージギミックや、強力なスキルを持つ敵も登場しますが、プレイヤーはタイピング速度の向上や戦略の洗練、デッキのアップデートを武器に、これらを乗り越えていきます。\n\nプレイヤーのタイピング速度に合わせたレベルで開始でき、進行に応じて難易度が徐々に上がる設計により、物語が進むにつれ、タイピングの腕前も自然と成長するようデザインされています。',
  '2611:97': '本作品は、「Inscryption」「DeathJack」「Liar’s Bar」「Buckshot Roulette」といったタイトルに見られる、一人称視点でボードゲームをプレイするようなスタイルを採用します。ゲーム内のオブジェクトや演出を自身の視点で体験することで、実際にボードゲームを遊ぶような直感的でわかりやすい体験を目指します。\n\nさらに、ボード上のエフェクトや動的な演出など、物理的なボードゲームではできない表現を加え、臨場感と世界への没入感を高めます。\n\nまた、ボード全体を常に見渡せるため、観戦時にもどちらが優勢かを把握しやすい構図です。MOBAやFPSのように一人のプレイヤーの周囲だけを映す画角と異なり、ゲーム実況や大会の配信でも、頻繁にカメラを切り替えずに、戦況や各プレイヤーの狙いを追いやすくなります。',
  '2611:56': sourceText.get('2611:56')!.replace('余地があります', '余地があると考えました').replace('どの駒をどの順番でどこに動かすかといった選択を', 'タイピング入力によるリソースで何を行うのかの選択を'),
  '2611:416': 'チェス盤のようなマス目があり、その上に自分のコマと相手のコマが乗っています。\n\nプレイヤーは自分のコマを選択して移動する方向を選択し、提示された文字列を入力してタイピングの課題をクリアすると、その方向にコマを１手動かせます。',
  '2611:421': 'そうしてコマを動かしていき、相手側の端から盤外にコマを落とすと相手にダメージを与えることが出来ます。\n先に相手の体力を削り切った方が勝利です。\n\nどのコマをどの順でどう移動させるか、考えながら素早くタイピングをすることで勝利を掴めます。',
  '2611:140': sourceText.get('2611:140')!.replace('20世紀以前からから', '以前から').replace('従来のタイトルはシンプルなスコア競争に留まり、視覚的進化や体験の広がりが不足しています。', '従来のeSportsとしてのタイピングゲームは、速さと正確さを競うだけで、視覚的な進化や戦術の広がりが少なく、観戦時の見どころがわかりづらい面があります。'),
  '2611:593': 'プレイ中は、テーブルと、テーブルを挟んで向かい合う相手が見えています。テーブル上のボードで、コマを生成したり移動させたりして戦います。必要な情報は、浮遊するウィンドウやハイライトで表示されます。\n\n盤面の横には大きなコンソールが浮いています。このウィンドウを選び、必要なコマンドを入力することで、新たなコマを生成できます。\n\n今後は、プレイ中にゲージが溜まると、同じくコンソールを使用して「アクティブスキル」を発動できるようにする予定です。全てのコマをランダムに動かすなど、ゲーム全体に影響する効果で逆転を狙えるため、発動のタイミングも重要です。\n\n相手が長くコマを動かしていない間は、コンソールで強力なコマやスキルを準備している可能性があるため、注意が必要です。',
};

function Link({ href, children }: { href: string; children: React.ReactNode }) {
  return <a className="text-link" href={href} target={href.startsWith('mailto:') ? undefined : '_blank'} rel="noreferrer">{children}<ArrowUpRight size={16}/></a>;
}
function Video({ id, title }: { id: string; title: string }) {
  return <figure className="reference-video"><iframe src={`https://www.youtube-nocookie.com/embed/${id}`} title={title} width="960" height="540" loading="lazy" allow="encrypted-media; picture-in-picture; fullscreen" referrerPolicy="strict-origin-when-cross-origin" allowFullScreen/><figcaption>{title}</figcaption></figure>;
}
function Text({ id }: { id: string }) {
  const text = corrections[id] ?? sourceText.get(id);
  if (!text) throw new Error(`Missing original text: ${id}`);
  return <div className="copy original-copy" data-source-id={id}>{text.trim().split(/(?:\r?\n){2,}/).map((paragraph, i) => <p key={i}>{paragraph.trim()}</p>)}</div>;
}
function Block({ title, ids }: { title: string; ids: string[] }) {
  return <div className="text-block"><h3>{title}</h3>{ids.map(id => <Text key={id} id={id}/>)}</div>;
}
const supplementaryCorrections: Record<string, string> = {
  'Solo mode / text': 'ローグライト\n\n戦闘とイベントを選びながら進み、コマの獲得・強化でデッキを育て、ボスの攻略を目指す1人用モードです。\n\n戦いや会話を通じて、記憶を失ったプレイヤーが自分の正体や世界の過去を知り、行動を選んでいく物語も描きます。\n\n現在：マップ進行と会話の骨格を実装。\n開発予定：報酬・強化、1周の完走、ボス、セーブ。物語は開発の進捗に合わせて内容と公開時期を調整します。',
  'Versus mode / text': 'オンライン対戦\n\n同じ盤面で他のプレイヤーと1対1で戦い、入力速度と戦略を競うモードです。フレンドとの対戦にも対応します。\n\n現在：オンライン対戦の基礎を実装し、1ラウンドで決着する対戦を遊べます。\n開発予定：通信の安定性・対戦導線・バランスを調整。ラウンド間に強化を挟む形式など、対戦モードのバリエーションも検討しています。',
  'Contact / text': 'BogosorGames\n\n金井啓太\n\nelectro.peaceful.oooo@gmail.com\n\nデモ・プレイ映像は、本資料とあわせて個別に共有します。\n大会・コミュニティ運営の可能性について、ぜひお話しさせてください。',
  'Tournament first event / text': '01  小規模な交流戦\n\n初参加者向けの練習時間を設け、ルールを共有する、招待制の対戦会をご相談させていただければと思います。\n\n確認したいこと\n試合の進めやすさ、参加者の反応、通信・運営上の課題。',
  'Tournament broadcast / text': '02  配信付き大会\n\nタイピング競技者や配信者を招き、対戦の見どころを実況で伝える大会を開催できればと考えています。\n\n会場・オンライン形式、参加人数、実況・配信体制は、パートナーとご相談のうえ、一緒に検討させていただければと思います。',
  'Tournament community / text': '03  継続する対戦会\n\nイベント後も対戦相手が見つかる場づくりや、参加者の声を調整と次の開催に反映する進め方をご相談させていただければと思います。\n\nコミュニティでの交流戦を繰り返し、その反応をゲームバランスの調整にも活かします。再参加・継続プレイを確かめながら、コミュニティを育てていきたいと考えています。',
};
function Existing({ slide, name }: { slide: number; name: string }) {
  const entry = previous[slide].text.find(t => t.name === name);
  if (!entry) throw new Error(`Missing supplementary text: ${name}`);
  return <div className="copy supplementary-copy">{(supplementaryCorrections[name] ?? entry.text).split('\n\n').map((part, i) => i === 0 ? <h3 key={i}>{part}</h3> : <p key={i}>{part}</p>)}</div>;
}
function Note({ children }: { children: React.ReactNode }) { return <p className="note editorial-note">{children}</p>; }
function Slot({ name }: { name: SlotKey }) {
  const slot = imageSlots[name];
  return <figure className="asset-slot" data-slot={slot.id}>
    {slot.src ? <a href={slot.href || slot.src} target="_blank" rel="noreferrer"><img className="slot-image" src={slot.src} alt={slot.title} width="1280" height="720" loading="lazy"/></a> : <div className="placeholder"><div className="placeholder-top"><span>IMAGE {slot.id}</span><ImageIcon size={22}/></div><div><strong>{slot.title}</strong><p>{slot.brief}</p></div><code>{slot.file}</code></div>}
    {slot.caption && <figcaption>{slot.caption}</figcaption>}
  </figure>;
}
function Screenshot({ src, caption, alt }: { src: string; caption?: string; alt?: string }) {
  return <figure className="screenshot"><img src={src} alt={alt ?? caption ?? ''} width="1920" height="1080" loading="lazy"/>{caption && <figcaption>{caption}</figcaption>}</figure>;
}
function PieceArt({ pieces }: { pieces: string[] }) {
  return <div className="piece-art" aria-hidden="true">{pieces.map(piece => <img key={piece} src={`/images/piece-${piece}.png`} alt="" width="512" height="512"/>)}</div>;
}
function PieceOverview() {
  return <div className="copy piece-overview" data-source-id="2611:582">
    <p>コマごとに「移動コスト」「生成コスト」「移動方向」「アビリティ」が異なります。</p>
    <p>「今あるコマを動かすか、新しく生成するか」「どの方向から攻め、どこを守るか」。必要な入力の多さと移動できる方向を踏まえ、行動を選びます。</p>
    <p>新しいコマは、手元のコンソールで選び、タイピング課題をクリアして生成します。どのコマを出すかも重要な選択です。</p>
    <p>また、コマの強さや数に応じて、デッキ全体の入力コストも変わる設計を予定しています。課題の数ではなく、入力する文字列の長さに影響するため、戦力と打ちやすさのバランスも考えてデッキを組みます。</p>
  </div>;
}
function SectionArt({ chapter }: { chapter: string }) {
  if (chapter === 'contact') return <img className="section-scene" src="/images/world.webp" alt="" aria-hidden="true"/>;
  if (chapter === 'devices') return <img className="heading-inset" src="/images/key-enter.png" alt="" aria-hidden="true" width="827" height="1102"/>;
  return null;
}
function Foot({ number }: { number: string }) { return <div className="print-footer">NyctoType / BogosorGames <span>{number}</span></div>; }

type Chapter = { id: string; title: string; label: string; source?: string; className?: string; body: React.ReactNode };
const chapters: Chapter[] = [
  { id: 'concept', title: 'コンセプト', label: 'CONCEPT', source: '2611:50', body: <><Block title={sourceText.get('2611:55')!} ids={['2611:56']}/><Slot name="concept"/></> },
  { id: 'team', title: '開発体制', label: 'TEAM', source: '2611:64 2611:74', className: 'team original-team', body: <><div className="text-block"><h3 className="team-name">BogosorGames<Link href="https://bolcof.github.io/BogosorStudioWeb/">Webサイト</Link></h3><div className="copy"><p>現代美術をバックグラウンドに、映像・パフォーマンスなどの作品制作や、国内外のコンペティションへの参加・展示を経験してきました。</p><p>こうした制作活動で培った経験を、ゲームのコンセプトやメカニクスなど、体験の設計に活かして開発しています。</p></div></div><div className="support" aria-labelledby="support-heading"><h3 id="support-heading">採択・支援実績</h3><Link href="https://tgca.jp/">TGCA 第1期 育成クリエイター</Link><Link href="https://ponos-foundation.org/support.html">公益財団法人ポノス財団 助成採択：『NyctoType』の大会用バージョン開発</Link></div></> },
  { id: 'rules', title: '基本ルール', label: 'RULES', source: '2611:409', className: 'rules', body: <><Screenshot src="/images/gameplay-current.png" caption="開発中の実機画面：盤面・移動先の選択・両者の体力"/><div className="two-columns body-after-media"><Text id="2611:416"/><Text id="2611:421"/></div><ol className="rule-steps"><li><Slot name="ruleSelect"/></li><li><Slot name="ruleDirection"/></li><li><Slot name="ruleTyping"/></li><li><Slot name="ruleDamage"/></li></ol></> },
  { id: 'pieces', title: 'コマの種類', label: 'PIECES', source: '2611:572', body: <><div className="illustrated-copy"><PieceOverview/><PieceArt pieces={['killer', 'pusher']}/></div></> },
  { id: 'passive', title: 'アビリティ', label: 'ABILITIES', source: '2611:572', body: <><div className="copy" data-source-id="2611:579"><p>アビリティは、コマに備わる特殊な効果です。</p><p>「相手のコマを破壊する」「押し出す」「ダメージを増やす」のほか、「破壊を防ぐ」「移動時の入力文字数を減らす」といった効果があります。</p><p>コマの種類ごとにアビリティが決まっています。今後は、強化によってアビリティを追加できるようにする予定です。相手のアビリティも踏まえ、どのコマで攻め、どのコマを止めるかを判断します。</p></div><Slot name="abilities"/></> },
  { id: 'screen', title: '画面イメージ', label: 'SCREEN', source: '2611:584', body: <><div className="split"><Text id="2611:593"/><Screenshot src="/images/console-current.png" caption="開発中の実機画面：コンソールで生成するコマを選択"/></div></> },
  { id: 'artwork', title: '一人称視点で見る不穏な世界', label: 'ARTWORK', source: '2611:91', className: 'original-artwork artwork-references', body: <div className="artwork-layout"><Block title="没入感の高いゲームプレイのための一人称視点" ids={['2611:97']}/><aside className="artwork-gallery" aria-label="画角・演出の参考作品"><p className="artwork-reference-label">画角・演出の参考作品</p>{artworkReferences.map(game => <figure key={game.href}><a href={game.href} target="_blank" rel="noreferrer" aria-label={game.title + 'のSteamページを開く'}><img src={game.src} alt={game.title + 'のゲーム画面'} width={game.width} height={game.height}/><figcaption>{game.title}<ArrowUpRight size={14} aria-hidden="true"/></figcaption></a></figure>)}</aside></div> },
  { id: 'world', title: '世界観・物語', label: 'WORLD / STORY', className: 'story-world', body: <><Screenshot src="/images/world.webp" alt="NyctoTypeのゲーム内世界"/><div className="stack"><div className="text-block"><h3>PCの中で戦うプログラム</h3><div className="copy"><p>プレイヤーが見ている世界は、実はPCの内部です。プレイヤーも対戦相手もプログラムであり、互いにバグを送り合い、相手を破壊するために戦っています。</p></div></div><div className="text-block"><h3>ゴミ箱フォルダで目覚める主人公</h3><div className="copy"><p>プレイヤーは記憶を失い、PC内部を可視化した空間の「ゴミ箱フォルダ」で目覚めます。案内役のJunkから戦い方を教わり、外へ出るため、自分を排除しようとするプログラムを破壊しながら進みます。探索と記録の回収を通じて、世界の過去と自分の正体が少しずつ明らかになります。</p></div></div><div className="text-block"><h3>国家AIに支えられた地下社会</h3><div className="copy"><p>地上環境が悪化し、人類は地下シェルターで暮らしながら、先の見えない未来への判断を国家AIに委ねています。国家AIのメモリ不足を補うため、人間の記憶容量も社会インフラとして管理され、個人の生活や感情に関わる記憶と、国家のための記憶が、区別できない形で保持されています。</p><p>主人公は、国家AIの中核へ徴用された「天才」から、価値判断や意志を危険なノイズとして切り離された人格です。一方、JunkはAIの予測を絶対的な真実とは考えていなくても、人々が生き続けるための希望を維持しようとしています。国家の単純な悪意ではなく、社会を維持する合理性と個人の尊厳の衝突を、物語の中心に据えています。</p></div></div></div></> },
  { id: 'solo', title: 'ローグライト要素を含んだストーリーモード', label: 'GAME MODE', source: '2611:103', className: 'solo-mode', body: <><div className="two-columns"><div className="text-block"><h3>ローグライト</h3><div className="copy"><p>戦闘やイベントのあるマップを進み、コマの獲得・強化でデッキを育てながら、ボスの攻略を目指す1人用モードです。</p><p>新しいコマを加えるか、手持ちのコマにアビリティを追加するか。獲得した報酬に合わせて構成を変え、次の戦闘に備えます。タイピングの腕前だけでなく、その挑戦でどんなデッキを作るかも重要になります。</p><p>ローグライトの戦闘と、敵やイベント、会話を通した世界観の提示を軸に、記憶や世界の過去を辿る物語を作り込んでいきます。各要素をどの段階で公開するかは、開発の進捗やプレイヤーの反応を見ながら調整します。</p></div><Slot name="solo"/></div><div className="text-block"><h3>物語とステージ</h3><Text id="2611:113"/><Screenshot src="/images/story-dialogue.png" caption="開発中の実機画面：Junkとの会話"/></div></div></> },
  { id: 'versus', title: '対戦モード', label: 'GAME MODE', source: '2611:103', body: <><Text id="2611:109"/><Video id="8GM8g_T3FFU" title="NyctoType 2026.09.09 Build CPUbattle"/></> },
  { id: 'market', title: 'なぜ今、タイピングなのか', label: 'MARKET', source: '2611:87 2611:117 2611:132', body: <><div className="two-columns"><Block title="歴史的価値と未開拓の可能性" ids={['2611:140']}/><Block title="参加へのハードルの低さ" ids={['2611:143']}/></div><Video id="zNrgd8MnGU4" title="REALFORCE TYPING CHAMPIONSHIP 2023 大会紹介 / 日テレスポーツ【公式】"/></> },
  { id: 'esports', title: 'eSportsとの親和性', label: 'COMPETITIVE PLAY', source: '2611:157 2611:117', className: 'original-esports', body: <EsportsSection/> },
  { id: 'streaming', title: '対戦実況による認知と訴求効果', label: 'STREAMING', source: '2611:185', className: 'streaming original-streaming', body: <><Block title="対戦形式による実況動画" ids={['2611:192']}/><div className="streaming-media"><Video id="WTJljoK-qbE" title="第2回 にじさんじ打鍵王 / 鈴木勝"/><Video id="bMiIeThZcpY" title="ストリートファイター6：ボンちゃん vs ウメハラ / レッドブルプレイ"/></div><Note>配信市場の参考事例です。本作の配信実績・出演予定・提携を示すものではありません。</Note></> },
  { id: 'sales-points', title: 'セールスポイント', label: 'SALES POINT', source: '2611:197', body: <div className="stack"><Block title="タイピングそのものの奥深さ" ids={['2611:205']}/><Block title="駆け引きを産むゲームシステム" ids={['2611:207']}/><Block title="ダークでシックな世界観" ids={['2611:206']}/></div> },
  { id: 'tournament', title: '大会の開催', label: 'TOURNAMENT', source: '2611:208', body: <><Text id="2611:217"/><div className="text-block partner-details"><h3>大会に向けて相談したい支援</h3><ul className="support-list"><li><strong>運営補助：</strong>大会の企画、進行、参加者対応など、開催に必要な運営への協力。</li><li><strong>招待参加者の紹介：</strong>ストリーマー、タイピング競技者、インフルエンサーとの接点づくりや、参加の打診。</li><li><strong>賞金・賞品の提供：</strong>大会の賞金や賞品の提供、協賛先の紹介。</li></ul></div><Video id="zNrgd8MnGU4" title="REALFORCE TYPING CHAMPIONSHIP 2023 大会紹介 / 日テレスポーツ【公式】"/><Note>実施時期・配布するビルド・開催形式は、パートナーと相談して決めさせていただければと思います。</Note></> },
  { id: 'devices', title: 'ゲーミングデバイス制作企業との協業', label: 'DEVICE PARTNERS', source: '2611:208', className: 'with-heading-inset', body: <div className="device-layout"><div><Text id="2611:216"/><div className="text-block partner-details"><h3>機材提供の実績</h3><p>台北ゲームショウ2026では、EPOMAKER・LINSOULより展示用キーボード・オーディオ機器の提供を受けました。</p></div><Note>今後のコラボ製品や大会協賛についても、ご相談させていただければと思います。</Note></div><Slot name="keyboard"/></div> },
  { id: 'sales-plan', title: '販売計画', label: 'SALES PLAN', source: '2611:233', body: <>
    <div className="sales-facts"><Block title="販売価格" ids={['2611:242']}/><Block title="販売目標本数" ids={['2611:245']}/></div>
    <div className="sales-estimate"><Block title="売上（試算）" ids={['2611:246']}/></div>
    <div className="text-block language-details"><h3>対応予定言語</h3><p>日本語・英語・中国語（繁体字／簡体字）・ドイツ語</p><p>インターフェイスの表示言語と、タイピング入力課題の言語は、それぞれ別に設定できるようにする予定です。</p></div>
    <div className="sales-reference-group"><h3>販売目標の根拠・参考作品</h3><div className="sales-references">
      <article className="sales-reference"><a href="https://store.steampowered.com/app/398850/Epistory__Typing_Chronicles/" target="_blank" rel="noreferrer"><img src="/images/reference-epistory.jpg" alt="Epistory - Typing Chronicles" width="460" height="215" loading="lazy"/></a><h4>Epistory - Typing Chronicles</h4><Text id="2611:249"/><Text id="2611:247"/><p className="sales-reference-source">中央値：VG Insights 約37.6万本</p><Link href="https://steamdb.info/app/398850/charts/">所有者推計の出典</Link></article>
      <article className="sales-reference"><a href="https://store.steampowered.com/app/944920/Nanotale__Typing_Chronicles/" target="_blank" rel="noreferrer"><img src="/images/reference-nanotale.jpg" alt="Nanotale - Typing Chronicles" width="460" height="215" loading="lazy"/></a><h4>Nanotale - Typing Chronicles</h4><Text id="2611:250"/><Text id="2611:248"/><p className="sales-reference-source">中央値：Gamalytic 約2.7万本</p><Link href="https://steamdb.info/app/944920/charts/">所有者推計の出典</Link></article>
      <article className="sales-reference"><a href="https://store.steampowered.com/app/2400160/Glyphica_Typing_Survival/" target="_blank" rel="noreferrer"><img src="/images/reference-glyphica.jpg" alt="Glyphica: Typing Survival" width="460" height="215" loading="lazy"/></a><h4>Glyphica: Typing Survival</h4><div className="copy"><p>980円 × 約19.9万本 ≒ 2.0億円（概算）</p><p>タイピングと武器・強化の選択を組み合わせたローグライト。ビルドを育てて繰り返し挑戦する点が、本作の1人用モードに近い参考例です。</p></div><p className="sales-reference-source">中央値：VG Insights 約19.9万本</p><Link href="https://steamdb.info/app/2400160/charts/">所有者推計の出典</Link></article>
    </div></div>
    <Note>3作品とも、SteamDB掲載の3社による所有者推計の中央値を販売本数とみなし、確認時点の日本通常価格（セール割引前）を掛けています。確認日：2026年9月9日。</Note>
    <Note>価格×推計本数の概算は実売上ではなく、割引・地域価格・税・返金・配布などを反映していません。所有者数と有料販売本数も一致するとは限りません。中央値の採用が精度を保証するものではなく、いずれも市場の参考です。</Note>
  </> },
  { id: 'schedule-original', title: '開発スケジュール', label: 'DEVELOPMENT ROADMAP', className: 'release-schedule', body: <ScheduleSection/> },
  { id: 'progress', title: 'これまでの歩み', label: 'HISTORY / COVERAGE', className: 'progress', body: <ProgressSection><Slot name="gamescom"/></ProgressSection> },
  { id: 'current-modes', title: 'ゲームモードの現在の開発方針', label: 'GAME MODES / CURRENT DRAFT', className: 'modes', body: <div className="two-columns"><Existing slide={5} name="Solo mode / text"/><Existing slide={5} name="Versus mode / text"/></div> },
  { id: 'event-plan', title: '大会・コミュニティ運営の相談案', label: 'TOURNAMENT / DISCUSSION', body: <><div className="three-columns"><Existing slide={10} name="Tournament first event / text"/><Existing slide={10} name="Tournament broadcast / text"/><Existing slide={10} name="Tournament community / text"/></div><Note>会場・参加人数・予算・時期は、協力先と相談して決めさせていただければと思います。</Note></> },
  { id: 'partnership', title: 'パートナーに相談したいこと', label: 'PARTNERSHIP', className: 'partnership', body: <><p className="partnership-intro">大会・コミュニティ運営と、展示会への出展を中心にご相談させていただければと思います。以下すべての支援を前提とするものではなく、一部のみのご協力も含め、ご対応いただける範囲に応じて内容や役割分担をご相談できればと考えています。</p><div className="two-columns partner-details"><div className="text-block"><h3>大会・コミュニティ運営</h3><ul className="support-list"><li>大会・交流戦の企画、運営補助</li><li>招待参加者の紹介、参加者・配信者へのアプローチ</li><li>賞金・賞品の提供、協賛先の紹介</li><li>実況・配信制作</li><li>継続するコミュニティの運営</li></ul></div><div className="text-block"><h3>展示会への出展</h3><div className="copy"><p>国内外のゲーム展示会への共同出展や、出展機会の紹介を通じて、本作を来場者・メディア・関係者に届ける機会を増やしたいと考えています。</p><p>ブースへの作品展示や現地での展示運営など、ご協力いただける内容をご相談させていただければと思います。</p></div></div></div><div className="text-block partner-details"><h3>開発チームが担うこと</h3><div className="copy"><p>ゲーム開発、ビルド提供、ルール説明、イベントで得た課題への対応。</p><p>対戦イベントや展示への参加に向け、開催形式・役割分担・必要なゲーム機能からご相談させていただければと思います。</p></div></div><Link href={'mailto:' + email}>メールで連絡する</Link></> },
  { id: 'contact', title: 'デモ・連絡先', label: 'CONTACT', className: 'contact scene-section', body: <><div className="split"><div><Existing slide={14} name="Contact / text"/><div className="source-links"><Link href={'mailto:' + email}>メール</Link><Link href={steam}>SteamでNyctoTypeを見る</Link></div></div><Video id="8GM8g_T3FFU" title="NyctoType 2026.09.09 Build CPUbattle"/></div></> },
];

export default function Home() {
  return <>
    <a className="skip-link" href="#contents">目次へ</a>
    <header className="site-header"><a className="wordmark" href="#cover">NyctoType<span> / BogosorGames</span></a><nav aria-label="メイン"><a href="#contents">目次</a><a href="#streaming">配信・大会</a><a href="#partnership">協業</a><div className="language-switcher" data-language-switcher="true" role="group" aria-label="Language"><button type="button" data-pitch-language="ja" aria-pressed="true" lang="ja">日本語</button><button type="button" data-pitch-language="en" aria-pressed="false" lang="en">English</button></div><PrintButton/></nav></header>
    <main>
      <section id="cover" className="cover print-page" data-figma-id="2611:43">
        <div className="hero"><img className="hero-image" src="/images/world.webp" alt="NyctoTypeのゲーム内世界" width="2400" height="800" fetchPriority="high"/><div className="wrap hero-content"><p className="eyebrow">PARTNER PITCH</p><h1>NyctoType</h1><p className="tagline">速度と戦術で競い合う<br/>マルチスレッドタイピングバトル</p><a className="button primary" href={steam} target="_blank" rel="noreferrer">Steamで見る<ArrowUpRight size={18}/></a><UpdateHistory/></div><a className="hero-down" href="#contents" aria-label="目次へ"><ArrowDown size={24}/></a></div>
        <div className="wrap cover-details" data-source-id="2611:49">
          <dl className="cover-facts">{coverFacts.filter(fact => !isAudienceFact(fact.label)).map(fact => <div key={fact.label}><dt>{fact.label}</dt><dd>{fact.value}</dd></div>)}</dl>
          <dl className="cover-audience">{coverFacts.filter(fact => isAudienceFact(fact.label)).map(fact => <div key={fact.label}><dt>{fact.label}</dt><dd>{fact.value}</dd></div>)}</dl>
        </div><Foot number="01"/>
      </section>
      <nav id="contents" className="pitch-contents wrap" aria-label="目次"><span className="section-index">CONTENTS</span><div>{chapters.map((chapter, i) => <a key={chapter.id} href={'#' + chapter.id}><span>{String(i + 2).padStart(2, '0')}</span>{chapter.title}</a>)}</div></nav>
      {chapters.map((chapter, i) => <section key={chapter.id} id={chapter.id} className={'deck-section print-page original-section ' + (chapter.className ?? '')} data-figma-id={chapter.source} data-chapter={chapter.id}><SectionArt chapter={chapter.id}/><div className="wrap section-inner"><header className="section-heading"><span className="section-index">{String(i + 2).padStart(2, '0')} / {chapter.label}</span><h2>{chapter.title}</h2></header>{chapter.body}</div><Foot number={String(i + 2).padStart(2, '0')}/></section>)}
    </main>
    <footer className="site-footer wrap"><p><strong>NyctoType</strong><span>BogosorGames</span></p><div><Link href={steam}>Steam</Link><a href="#contents">目次へ戻る</a></div></footer>
    <script id="pitch-translations" type="application/json" data-pitch-script="translations" dangerouslySetInnerHTML={{ __html: JSON.stringify(englishCopy).replaceAll('<', '\\u003c') }}/>
    <script src="/language-switcher.js" defer data-pitch-script="runtime"/>
  </>;
}
