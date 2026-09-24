import type { ReactNode } from 'react';
import { ArrowUpRight } from 'lucide-react';

const history = [
  { date: '2025.04', title: 'TGCA 第1期に採択', href: 'https://tgca.jp/' },
  { date: '2025.09', title: '東京ゲームショウ2025 出展', href: 'https://tgs.cesa.or.jp/2025/exhibition?category=organizers_projects&detail=15321' },
  { date: '2026.01', title: '台北ゲームショウ2026 出展', href: 'https://tgs.tca.org.tw/index_e.php' },
  { date: '2026.02', title: 'PONOS財団 助成採択', href: 'https://ponos-foundation.org/support.html' },
  { date: '2026.05', title: '東京ゲームダンジョン12 出展', href: 'https://gamedungeon.jp/events/tokyo12/exhibit_informations/2213' },
  { date: '2026.08', title: 'gamescom 2026 出展', href: 'https://www.gamescom.global/en/product/nyctotype' },
  { date: '2026.09', title: '東京ゲームショウ2026 出展', href: 'https://tgs.cesa.or.jp/2026/' },
];

const coverage = [
  { source: '4Gamer', title: 'NyctoType単独インプレッション', detail: '2026.09.24 / 日本語', href: 'https://www.4gamer.net/games/045/G104514/20260924028/' },
  { source: 'ファミ通.com', title: 'TGS2026出展とSteam体験版を紹介', detail: '2026.09.15 / 日本語', href: 'https://www.famitsu.com/article/202609/87998' },
  { source: '4Gamer', title: 'TGCAのgamescom取材記事内で作品紹介', detail: '2026.09.05 / 日本語', href: 'https://www.4gamer.net/games/991/G999110/20260905003/' },
  { source: 'IGN China', title: 'gamescomでの試遊レポート', detail: '中国語 / TapTap掲載', href: 'https://www.taptap.cn/moment/843052528860923924' },
  { source: '游民星空 / Gamersky', title: '2026年のインディー対戦ゲーム特集内で紹介', detail: '2026.05.07 / 中国語', href: 'https://www.gamersky.com/handbook/202605/2135918.shtml' },
  { source: '惡魔貓 / DevilCatwith2cats', title: '台北ゲームショウの訪問動画でNyctoTypeを紹介', detail: '2026.02.07 / 中国語 / YouTube', href: 'https://www.youtube.com/watch?v=TqYJ9ct6jD0' },
];

export function ProgressSection({ children }: { children: ReactNode }) {
  return <>
    <div className="copy journey-intro"><p>TGCAでの採択を経て、国内外の展示会に出展してきました。2026年9月には東京ゲームショウへ出展しました。一般向けSteam体験版は9月下旬に公開予定です。</p></div>
    <div className="journey-layout">
      <ol className="journey-timeline">{history.map(item => <li key={item.date}>
        <span className="journey-date">{item.date}</span>
        <a href={item.href} target="_blank" rel="noreferrer">{item.title}<ArrowUpRight size={16} aria-hidden="true"/></a>
      </li>)}</ol>
      <div className="journey-photo">{children}</div>
    </div>
    <div className="coverage-section"><h3>紹介記事・動画</h3>
      <ul className="coverage-list">{coverage.map(item => <li key={item.href}>
        <a href={item.href} target="_blank" rel="noreferrer"><span className="coverage-source">{item.source}</span><span className="coverage-body"><span>{item.title}</span><small>{item.detail}</small></span><ArrowUpRight size={18} aria-hidden="true"/></a>
      </li>)}</ul>
    </div>
  </>;
}
