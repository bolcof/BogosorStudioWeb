export const imageSlots = {
  concept: { id: '01', title: '入力と盤面が同時に見えるプレイ画面', brief: '攻撃と防御の判断が分かる最新スクリーンショット。タイピング課題・コマ・相手の動きが同じ画面に入るもの。', caption: 'NyctoTypeのプレイ画面', file: '01-concept.png', src: '/images/01-concept.png', href: '' },
  abilities: { id: '02', title: 'コマとアビリティの確認画面', brief: 'コマの能力が伝わる実画面。発動前と発動後を左右に並べた画像でも可。', caption: 'NyctoTypeのコマとアビリティ', file: '02-abilities.png', src: '/images/02-abilities.png', href: '' },
  solo: { id: '03', title: 'ローグライトのマップ（イメージ画像）', brief: '経路の選択、コマの獲得・強化が分かる最新の実画面。', caption: 'ローグライトのマップ（イメージ画像）', file: '03-solo.png', src: '/images/03-solo.png', href: '' },
  versus: { id: '04', title: 'オンライン対戦の実画面', brief: '対戦相手と両者の体力が分かる画面。2人が対戦している写真でも可。', caption: 'オンライン対戦の開発画面', file: '04-versus.jpg', src: '', href: '' },
  vtuberTyping: { id: '05', title: 'VTuberによるタイピングゲーム配信のサムネイル', brief: 'タイピング挑戦・記録更新などを扱う実在の配信。配信者名、動画タイトル、元動画URLも添える。', caption: '配信市場の参考事例。本作の配信実績ではありません。', file: '05-vtuber-typing.jpg', src: '', href: '' },
  vtuberBattle: { id: '06', title: 'VTuberの対戦・コラボ企画のサムネイル', brief: '複数人の対戦や大会が企画として伝わる実在の配信。本作以外の事例として掲載。元動画URLも添える。', caption: '対戦企画の参考事例。本作への出演予定を示すものではありません。', file: '06-vtuber-battle.jpg', src: '', href: '' },
  gamescom: { id: '07', title: 'gamescom 2026のNyctoType展示風景', brief: 'gamescom 2026で来場者がNyctoTypeを試遊している展示風景。', caption: 'NyctoType / gamescom 2026 展示風景', file: '07-gamescom.jpg', src: '/images/07-gamescom.jpg', href: '' },
  touchTypeTale: { id: '08', title: 'Touch Type Taleのゲーム画面', brief: 'タイピングで戦略ゲームを操作することが伝わる公式画像。出典URLを添える。', caption: '比較対象：Touch Type Tale', file: '08-touch-type-tale.jpg', src: '', href: 'https://store.steampowered.com/app/909470/' },
  glyphica: { id: '09', title: 'Glyphica: Typing Survivalのゲーム画面', brief: 'タイピングとビルド成長が伝わる公式画像。出典URLを添える。', caption: '比較対象：Glyphica: Typing Survival', file: '09-glyphica.jpg', src: '', href: 'https://store.steampowered.com/app/2400160/' },
  realforce: { id: '10', title: 'REALFORCE大会の公式告知・配信画面', brief: '競技者、対戦、観客や実況の存在が伝わる公式素材。大会名・開催年・出典URLを添える。', caption: '競技タイピングの参考事例。本作との提携・協賛を示すものではありません。', file: '10-realforce-tournament.jpg', src: '', href: 'https://www.youtube.com/watch?v=7sR6diUkWao' },
  gameplayVideo: { id: '11', title: 'NyctoTypeのプレイ動画サムネイル', brief: '30〜60秒程度で、入力→行動→ダメージまで伝わる動画。画像と完成した動画URLをセットで用意。', caption: 'NyctoType / プレイ動画', file: '11-gameplay-video.jpg', src: '', href: '' },
  keyboard: { id: '12', title: '台北ゲームショウ2026で使用した提供機材', brief: 'キーボードを実際に触っている場面、または製品と本作の画面を並べた写真。協業候補と既存実績を混同しない。', caption: '台北ゲームショウ2026で使用した提供機材', file: '12-keyboard.jpg', src: '/images/12-keyboard.jpg', href: '' },
  ruleSelect: { id: '13', title: 'コマを選択', brief: '移動させる自分のコマを選んだ場面。ほかの3枚と同じ解像度・画角で撮影。', caption: '移動の対象とする自分のコマを選択', file: '13-rule-select.png', src: '/images/13-rule-select.png', href: '' },
  ruleDirection: { id: '14', title: '方向を選択', brief: '移動方向を選んだ場面。ほかの3枚と同じ解像度・画角で撮影。', caption: '移動する方向を選択', file: '14-rule-direction.png', src: '/images/14-rule-direction.png', href: '' },
  ruleTyping: { id: '15', title: '文字列を入力', brief: '選択した移動のタイピング課題を入力している場面。ほかの3枚と同じ解像度・画角で撮影。', caption: '提示された文字列を入力', file: '15-rule-typing.png', src: '/images/15-rule-typing.png', href: '' },
  ruleDamage: { id: '16', title: 'ダメージ', brief: '相手側の盤外に落としてダメージを与えた場面。ほかの3枚と同じ解像度・画角で撮影。', caption: '相手側の盤外に落としたらダメージ！', file: '16-rule-damage.png', src: '/images/16-rule-damage.png', href: '' },
};
export type SlotKey = keyof typeof imageSlots;
