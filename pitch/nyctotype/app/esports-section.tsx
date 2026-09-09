const comparisons = [
  { title: '3つの要素', skill: '個人スキル', tactics: '駆け引き', uncertainty: '不確実性' },
  { title: '本作品', skill: 'タイピング速度', tactics: 'コマの動かし方', uncertainty: 'ランダムに現れる強化項目' },
  { title: 'FPS', example: '例：Apex Legends', skill: 'エイムの良さ', tactics: '位置取り', uncertainty: 'リング収縮位置・アイテムドロップ' },
  { title: '格闘ゲーム', example: '例：Street Fighter 6', skill: 'コンボ精度', tactics: '差し合い', uncertainty: '打撃・投げの択' },
];

export function EsportsSection() {
  return <div className="esports-layout">
    <div className="text-block">
      <h3>既存タイトルとの共通点</h3>
      <div className="copy" data-source-id="2611:171">
        <p>タイピングの競技大会はすでに開催されていますが、FPSや格闘ゲームと比べると、競技市場の広がりはまだ限られていると考えています。本作品では、タイピングゲームの性質を活かし、eSportsとしての展開を目指しています。</p>
        <p>競技性とエンタメ性を両立するため、「個人スキル」「駆け引き」「不確実性」の3つに着目しています。ある要素で劣っていても、他の要素で補えるバランスが重要だと考えています。</p>
        <p>本作品の「個人スキル」は「タイピング速度」です。練習によって勝率を上げられる一方で、自分より速い相手にも、コマの動かし方や、ランダムに現れる強化項目の選択によって逆転を狙える設計を予定しています。「スキルを向上する価値」と「どちらが勝つかわからない面白さ」の両立を目指しています。</p>
        <p>タイピングは多くの人が日常的に行うため、競技者の「凄さ」が自分ごととして伝わりやすいのも特長です。誰もが挑戦しやすく、上級者のパフォーマンスには見応えがあるという性質を、観戦の楽しさにもつなげます。</p>
      </div>
    </div>
    <div className="esports-diagrams">
      {comparisons.map((item, index) => <figure className={`esports-triangle${index === 0 ? ' triangle-key' : ''}`} key={item.title}>
        <figcaption><strong>{item.title}</strong>{item.example && <small>{item.example}</small>}</figcaption>
        <div className="triangle-body">
          <svg viewBox="0 0 400 60" preserveAspectRatio="none" aria-hidden="true"><path d="M200 2 L65 58 L335 58 Z"/></svg>
          <span className="triangle-top">{item.skill}</span>
          <span className="triangle-left">{item.tactics}</span>
          <span className="triangle-right">{item.uncertainty}</span>
        </div>
      </figure>)}
    </div>
  </div>;
}
