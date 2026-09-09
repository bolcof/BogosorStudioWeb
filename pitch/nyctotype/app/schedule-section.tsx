import { Gamepad2, Layers, Trophy, Users, Flag, Check } from 'lucide-react';

const stages = [
  {
    icon: Gamepad2,
    period: '2026年9月',
    timing: '出展・デモ公開',
    title: 'TGSへ出展',
    purpose: '試遊を通じて本作をなるべく広く届ける',
    details: [
      'TGSに出展し、会期に合わせて配布可能なデモをSteamストアで公開。',
      'gamescomで判明した不具合や、操作・表示を改善。',
    ],
    current: 'バトルの根幹となるシステムができており、チュートリアルとCPU戦、オンライン対戦を遊べます。数種類の特殊なコマと、それらを組み合わせたプリセットデッキを実装しています。',
  },
  {
    icon: Trophy,
    period: '2026年12月',
    timing: '目標',
    title: '対戦イベントに向けた準備',
    purpose: 'イベントで楽しめる対戦のバランスを整える',
    details: [
      'エフェクトやUIを改善し、戦況を見やすく調整。',
      'スキルを実装し、コマの特殊効果を拡充。',
      'コマの獲得・強化を整備し、対戦全体のバランスを調整。',
    ],
  },
  {
    icon: Layers,
    period: '2027年3月',
    timing: 'TGCA支援期間終了に向け、デモを整える',
    title: 'ローグライトの1周を完成',
    purpose: 'デッキを育て、最後まで遊べる1人用体験を作る',
    details: [
      'マップ、戦闘、イベント、報酬・強化を一連の流れに。',
      'ボス戦を含め、1周を最後まで遊べる状態に整備。',
      '会話やステージを通じて、デモに収録するローグライト1周分のストーリーを完成させ、世界観を伝える内容を制作。',
    ],
  },
  {
    icon: Users,
    period: '2027年7月',
    timing: '外部テスト期間',
    title: '外部テスト・改善',
    purpose: 'ソロ・対戦の両方を検証し、品質を高める',
    details: [
      '外部プレイヤーによるテストを繰り返し、操作性や難易度を確認。',
      'ネットワークの安定性・遅延、セーブなどの動作を検証。',
      'フィードバックを基に、不具合やゲームバランスを改善。',
    ],
  },
  {
    icon: Flag,
    period: '2027年10月',
    timing: '公開目標',
    title: 'アーリーアクセス',
    purpose: '販売を開始し、プレイヤーの反応を開発に活かす',
    details: [
      'ソロとオンライン対戦を備えた有料版を提供。',
      'ローカライズ、告知素材、Steamでの配信準備。',
      '公開後も内容の追加と調整を継続。',
    ],
  },
  {
    icon: Check,
    period: '2027年12月',
    timing: '発売目標',
    title: '正式リリース',
    purpose: '収録内容と品質を整え、正式版を届ける',
    details: [
      '収録内容と物語の範囲を固め、演出・翻訳を仕上げ。',
      'アーリーアクセスで得た反応を反映し、最終的な動作検証と調整。',
    ],
  },
];

export function ScheduleSection() {
  return <>
    <ol className="release-timeline">
      {stages.map(({ icon: Icon, ...stage }, index) => <li key={stage.period} data-stage={index + 1} className={index === 0 ? 'release-current' : index >= 4 ? 'release-launch' : ''}>
        <div className="release-period"><strong>{stage.period}</strong><span>{stage.timing}</span></div>
        <div className="release-node"><Icon size={22} aria-hidden="true"/><span aria-hidden="true">{String(index + 1).padStart(2, '0')}</span></div>
        <h3>{stage.title}</h3>
        <div className="release-purpose"><h4>目的</h4><p>{stage.purpose}</p></div>
        <div className="release-details"><h4>詳細</h4><ul>{stage.details.map(detail => <li key={detail}>{detail}</li>)}</ul></div>
        {stage.current && <div className="release-status"><h4>現在できること</h4><p>{stage.current}</p></div>}
      </li>)}
    </ol>
    <div className="release-parallel"><Users size={22} aria-hidden="true"/><p>オンライン対戦は、ソロの機能追加と並行して整備します。試遊や対戦イベントでの反応も、開発と運営の検証に活かしていきます。</p></div>
    <p className="note editorial-note">各年月は現時点での目標です。各段階の内容や公開時期は、開発の進捗と検証結果に応じて調整します。</p>
  </>;
}
