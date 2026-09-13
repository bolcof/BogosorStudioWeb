# NyctoType メディア向けプレスキット

ゲームメディア・配信者が紹介や動画制作に使う資料です。パブリッシャー向けピッチとは別に管理します。

## 編集と生成

- 正本の文章: `content.json`。日英の対を同時に更新してください。
- 素材一覧・出典: `assets.json`。
- 配布用原寸画像: `../../docs/presskits/NyctoType/assets/`。コピー済みの素材を使うため、ゲーム側リポジトリは再生成時に不要です。
- ページの構成: `build.cjs`。スタイル・言語切り替え: `presskit.css`、`presskit.js`。
- 出力先: `../../docs/presskits/NyctoType/`。生成したHTML、プレビュー、ZIP、TXTを直接編集しないでください。

Node.jsとGoogle Chromeを使用します。このディレクトリで依存関係を導入して実行します。

```sh
npm install
npm run build
npm run check
```

この端末の既存ランタイムを使う場合（リポジトリのルートから）:

```sh
NODE_PATH=/Users/244cm265kg/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules /Users/244cm265kg/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node press/nyctotype/build.cjs
NODE_PATH=/Users/244cm265kg/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules /Users/244cm265kg/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node press/nyctotype/check.cjs
```

ページはローカルHTMLとして開けます。英語表示で開く場合はURLに `?lang=en` を付けます。検証処理は一時的なローカルHTTPサーバーを使用し、終了時に閉じます。

## 採用素材と加工

| 配布ファイル | 原寸 | 出典・用途 | ページ用プレビュー |
| --- | --- | --- | --- |
| NyctoType-01-board_JP.png | 3840 × 2160 | ユーザー差し替え / 盤面と移動先選択 | 1200 × 675 WebP |
| NyctoType-01-board_ENG.png | 3840 × 2160 | ユーザー追加 / 盤面と移動先選択 | 1200 × 675 WebP |
| NyctoType-02-console_JP.png | 3840 × 2160 | ユーザー差し替え / コマ生成 | 1200 × 675 WebP |
| NyctoType-02-console_ENG.png | 3840 × 2160 | ユーザー追加 / コマ生成 | 1200 × 675 WebP |
| NyctoType-03-typing_JP.png | 3840 × 2160 | ユーザー差し替え / タイピング課題 | 1200 × 675 WebP |
| NyctoType-03-typing_ENG.png | 3840 × 2160 | ユーザー追加 / タイピング課題 | 1200 × 675 WebP |
| NyctoType-04-attack_JP.png | 3840 × 2160 | ユーザー差し替え / 盤外に落としてダメージ | 1200 × 675 WebP |
| NyctoType-04-attack_ENG.png | 3840 × 2160 | ユーザー追加 / 盤外に落としてダメージ | 1200 × 675 WebP |
| NyctoType-05-piece_JP.png | 3840 × 2160 | ユーザー追加 / 特殊なアビリティを持つコマ | 1200 × 675 WebP |
| NyctoType-05-piece_ENG.png | 3840 × 2160 | ユーザー追加 / 特殊なアビリティを持つコマ | 1200 × 675 WebP |
| NyctoType-06-story_JP.png | 3840 × 2160 | ユーザー追加 / ストーリー会話 | 1200 × 675 WebP |
| NyctoType-06-story_ENG.png | 3840 × 2160 | ユーザー追加 / ストーリー会話 | 1200 × 675 WebP |
| NyctoType-logo.png | 5000 × 2387 | 指定されたTitleView/logo.png / 透過ロゴ | 1200 × 573 WebP、透過維持 |
| NyctoType-cover-image.png | 1200 × 1500 | ユーザー追加 / 縦型キーアート | 960 × 1200 WebP |
| NyctoType-wide-art-logo.png | 3840 × 1280 | ユーザー追加 / ロゴ入り横長キーアート | 1200 × 400 WebP |
| Square.png | 1000 × 1000 | ユーザー追加 / 正方形キーアート | 1000 × 1000 WebP |
| NyctoType-wide-art.png | 3840 × 1240 | LibraryHero.png / 横長アート | 1200 × 388 WebP |

- 配布用PNGはファイル名のみ変更した原寸コピーです。原本は変更していません。
- ページ用プレビューのみ、縦横比を保って最大幅1200pxへ縮小し、WebP品質85に変換。拡大、切り抜き、文字入れ、色調補正、ロゴのデザイン加工はしていません。
- ロゴは透明部分と半透明の赤いキー図案があるPNGです。背景色により見え方が変わるため、合成表示でも確認しました。ページの灰色背景はCSSであり、配布画像には含まれません。
- スクリーンショットは日本語UI・英語UIの6場面、計12枚。ページでは選択中の言語に対応する6枚だけを表示します。Unityのデバッグ表示は含みません。
- `docs/assets/games/NyctoType/KeyArt.png` は名前に反して実ゲーム画面で、今回の画像と構図が重なるため不採用です。
- 旧600 × 900pxキーアート、仮マップ、生成イメージ、他作品の画像、第三者動画サムネイル、既存トレーラーは不採用です。

## 内容の根拠と確認

- 2026-09-12時点のWebサイト側 `pitch/nyctotype/app/page.tsx`、`schedule-section.tsx`、引き継ぎ文書を参照。ゲーム側の古いピッチは読み戻していません。
- ユーザー承認: 発売予定は「2027年にアーリーアクセス配信予定」まで。月と正式版時期は掲載しません。
- ユーザー指定: 現在は日本語、英語、中国語（繁体字・簡体字）。将来はこの4言語に、Steam利用言語で上位のロシア語、スペイン語、ポルトガル語、ドイツ語を加えた主要8言語を予定。UI言語とタイピング課題の入力言語を個別に設定する予定も説明。
- ユーザー指定: 現在の開発内容の一覧は掲載しません。製品版の予定は個別デモの収録内容とは区別します。
- 最新情報: 東京ゲームショウ2026は幕張メッセ ホール10／ブース10-E17に出展予定。一般向けデモは2026年9月下旬にSteamで公開予定。
- 2026-09-12付の日本語プレスリリースを、素材ZIPとは別の平文TXTとしてトップから直接ダウンロードできるようにします。
- 最新ピッチのeSports説明をもとに、タイピングゲーム自体をより多くの人が遊び、観戦し、参加するeスポーツへ育てる目標を、一般向けの短い文章で掲載します。
- TJさんに渡すデモのUIは4言語、入力は現時点で英語のみ。具体的な4言語の内訳は未確認のため、公表文には使っていません。デモの案内メールで伝える情報です。
- ユーザー承認: デモ受領後すぐ動画・配信を公開可能。広告・投げ銭による収益化可。
- ユーザーの最新指定: クレジットとSteamリンクは任意。可能であれば掲載をお願いする表現です。
- ユーザー承認: 紹介用の画像利用可。利用者によるスクリーンショットとキーアートのリサイズ・トリミング・文字入れ可。ロゴは縦横比を保った拡大縮小のみ可、デザイン改変不可。
- Steamの表示（確認時点）は発売日未発表、3言語、開発元Bogosor Studioです。プレスキットはユーザー承認の新しい情報とBogosorGames表記を優先しました。Steamの更新は別作業です。

## 配布と公開

ZIPは日本語版と英語版を分け、各ZIPに対応言語のスクリーンショット6枚、共通のロゴ・キーアート5枚、対応言語のTXT 1点（計12ファイル）のみを明示的に収録します。ビルド、デモの個別リンク、編集元、内部資料、プレビュー、トレーラーは入りません。

この作業ではpush・外部公開・メール送信は行いません。既存の紹介ページからピッチへのリンクも変更しません。`noindex` は検索除外の指定であり、アクセス制限ではありません。`docs/` を公開する変更をpushすれば本資料も公開対象になるので、事前にユーザーの確認を受けてください。

検証内容: ZIPの許可リスト・ファイル一致、ロゴ透過、翻訳の切り替えと復元、1440/390/320px幅の表示、全セクションリンク、PNG/ZIP/TXTのブラウザーダウンロード、ローカルリンク、英語直リンク。確認画像はGit対象外の `verification/` に保存します。
