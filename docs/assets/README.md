# BogosorStudio Web アセット管理

このフォルダには、サイトで使う画像アセットを置きます。
Steam向けのストア画像・ライブラリ画像を、下記の命名規則に合わせて配置してください。

## タイトル情報の編集

タイトル名、Steam / X のリンク、対応プラットフォームなどは、リポジトリ直下の `games.csv` で編集します。
トップページのカード説明、カードラベル、各タイトルページのサマリー、ページラベル、概要、今後の予定、活動記録は `content/games/<TitleId>.md` で編集します。
Markdown内の改行は概要本文に反映され、`今後の予定` と `活動記録` の箇条書きはそのままリスト表示されます。
トップページのカードに表示するラベルは `## カードラベル` / `## Card Labels`、各タイトルページ上部に表示するラベルは `## ページラベル` / `## Page Labels` に箇条書きで書きます。
先頭の色タグで見た目を切り替えます。

- `(main)` - 基本の強調ラベル。地の色=オレンジ、字の色=白
- `(released)` - 発売中ラベル。地の色=ミントグリーン、字の色=黒
- `(event)` - 展示・出展ラベル。地の色=金、字の色=黒
- `(muted)` - 補助ステータス。地の色=半透明グレー、字の色=白

カードにラベルを出したくない場合は、`## カードラベル` をコメントだけにして箇条書きを空にします。

`games.csv` または `content/games/<TitleId>.md` を編集したあと、次のコマンドを実行してください。

```sh
ruby scripts/apply_games_csv.rb
```

このコマンドで、次のHTMLに内容が反映されます。

- `docs/index.html`
- `docs/games/<TitleId>.html`

## タイトル別アセットの命名規則

各タイトルごとに、個別ページと同じ `TitleId` のフォルダを作ります。

```text
docs/games/<TitleId>.html
docs/assets/games/<TitleId>/
```

フォルダ内では、できるだけ次の名前に揃えてください。

- `KeyArt.png` - 個別ページ用の大きな背景画像
- `LibraryCapsule.png` - ホームのゲーム一覧で使う縦長カプセル画像。目安は600x900
- `LibraryHero.png` - 個別ページのヒーロー背景画像。目安は3840x1240
- `ScreenShot01.png` - 個別ページのスクリーンショット
- `ScreenShot02.png` - 個別ページのスクリーンショット
- `ScreenShot03.png` - 個別ページのスクリーンショット
- `OgImage.png` - SNS共有用画像。任意

例:

```text
docs/games/Reversi2048.html
docs/assets/games/Reversi2048/KeyArt.png
docs/assets/games/Reversi2048/LibraryCapsule.png
```

`LibraryCupsule.png` は古いスペルミスです。
今後は `LibraryCapsule.png` を使ってください。

## スタジオ共通アセット

- `studio/logo.png` - ヘッダー用のロゴまたはワードマーク
- `studio/hero.jpg` - トップページのスライド用画像
- `studio/news.jpg` - Newsセクション用画像
- `studio/og-image.jpg` - サイト全体のSNS共有用画像。目安は1200x630

## 現在使っているタイトルアセット

- `games/SakWinik/LibraryCapsule.png`
- `games/SakWinik/LibraryHero.png`
- `games/SakWinik/KeyArt.png`
- `games/SakWinik/OgImage.png`
- `games/SakWinik/ScreenShot01.png`
- `games/SakWinik/ScreenShot02.png`
- `games/SakWinik/ScreenShot03.png`
- `games/Reversi2048/LibraryCapsule.png`
- `games/Reversi2048/LibraryHero.png`
- `games/Reversi2048/KeyArt.png`
- `games/Reversi2048/ScreenShot01.png`
- `games/Reversi2048/ScreenShot02.png`
- `games/Reversi2048/ScreenShot03.png`
- `games/SkillHockey/LibraryCapsule.png`
- `games/SkillHockey/LibraryHero.png`
- `games/NyctoType/LibraryCapsule.png`
- `games/NyctoType/LibraryHero.png`
- `games/HAPPYRUNNER/LibraryCapsule.png`

一部の画像がまだないタイトルでも、ページ自体は表示できます。
画像を追加したら、命名規則に合わせて置くだけで差し替えやすい構成にしています。
