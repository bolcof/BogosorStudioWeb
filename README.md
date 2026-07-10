# BogosorStudioWeb

BogosorStudio公式サイト用の静的ファイルです。
GitHub Pagesでは `docs/` フォルダを公開対象にします。

## 公開ファイル

- `docs/index.html` - トップページ
- `docs/games/<TitleId>.html` - 各タイトルページ
- `docs/News/index.html` - News一覧ページ
- `docs/News/日付_タイトル/index.html` - News詳細ページ
- `docs/Exhibitions/index.html` - 展示・試遊・イベント出展情報ページ
- `docs/assets/` - サイトで使う画像アセット

## タイトル情報の編集

### 基本データ

タイトル名、Steam / X のリンク、対応プラットフォームなどの一覧向きメタ情報は、リポジトリ直下の `games.csv` で編集します。

トップページのカード説明、カードラベル、各タイトルページのサマリー、ページラベル、概要、今後の予定、活動記録は `content/games/<TitleId>.md` で編集します。

Markdown内の改行は概要本文に反映され、`今後の予定` と `活動記録` の箇条書きはそのままリスト表示されます。

### 対応プラットフォーム

トップページのカードに表示する対応プラットフォームは `meta_platform` で編集します。

複数ある場合は `Steam|Android|iOS` のように `|` 区切りで書きます。

対応プラットフォームアイコンの遷移先は、現状 `steam_url` を使います。Android / iOS の本番URLが未定の場合も、一旦Steamページへ飛ばします。

### 多言語ファイル

対応言語は `ja`, `en`, `de`, `zh-hant` です。

基本的には日本語版の `content/games/<TitleId>.md` を編集します。

日本語以外は `content/games/OtherLanguage/<TitleId>.<lang>.md` に置き、内容が変わったら英語、ドイツ語、繁体字のMDを同じ構造で更新します。

### ラベル

トップページのカードに表示するラベルは `## カードラベル` / `## Card Labels`、各タイトルページ上部に表示するラベルは `## ページラベル` / `## Page Labels` で別々に編集します。

ラベルは箇条書きで、先頭に色タグを書きます。

`(event)` は展示情報として金色で目立たせます。

ラベル欄が空の場合は、他の項目や日本語から自動補完せず、空のまま表示します。

### ヒーロースライダー

トップページ上部のヒーロースライダーは、タイトルとは別に `content/hero.md` で編集します。

日本語以外は `content/OtherLanguage/hero.<lang>.md` に置きます。

ヒーロースライダーはタイトル以外の告知も入れられるように、各スライドに `リンク`、`画像`、`タイトル`、`小見出し`、`ボタン` を書きます。

```md
## カードラベル

<!--
ラベルの色タグ:
- (main): 基本の強調ラベル。地の色=オレンジ、字の色=白
- (released): 発売中ラベル。地の色=ミントグリーン、字の色=黒
- (event): 展示・出展ラベル。地の色=金、字の色=黒
- (muted): 補助ステータス。地の色=半透明グレー、字の色=白
-->

- (event) 2026年8月 gamescom出展
- (event) 2026年9月 TGS出展

## ページラベル

<!--
ラベルの色タグ:
- (main): 基本の強調ラベル。地の色=オレンジ、字の色=白
- (released): 発売中ラベル。地の色=ミントグリーン、字の色=黒
- (event): 展示・出展ラベル。地の色=金、字の色=黒
- (muted): 補助ステータス。地の色=半透明グレー、字の色=白
-->

- (event) 2026年8月 gamescom出展
- (event) 2026年9月 TGS出展
- (muted) 開発中
```

カードにラベルを出したくない場合は、`## カードラベル` をコメントだけにして箇条書きを空にします。カードに出したい通常ラベルは `(main)`、発売中は `(released)` を使います。

`games.csv` または `content/games/<TitleId>.md` を編集したあと、次のコマンドを実行してください。

```sh
ruby scripts/apply_games_csv.rb
```

このコマンドで、次のHTMLに内容が反映されます。

- `docs/index.html`
- `docs/games/<TitleId>.html`

タイトル本文のMarkdownは、次の見出しを使います。

```md
## カード
## サマリー
## カードラベル
## ページラベル
## 概要
## 今後の予定
## 活動記録

## Card
## Summary
## Card Labels
## Page Labels
## About
## Plans
## History
```

ファイル名の例:

```text
content/games/NyctoType.md
content/games/OtherLanguage/NyctoType.en.md
content/games/OtherLanguage/NyctoType.de.md
content/games/OtherLanguage/NyctoType.zh-hant.md
```

ヒーロースライダーのファイル名:

```text
content/hero.md
content/OtherLanguage/hero.en.md
content/OtherLanguage/hero.de.md
content/OtherLanguage/hero.zh-hant.md
```

ヒーロースライダーの書き方:

```md
## スライド: NyctoType

- リンク: ./games/NyctoType.html
- 画像: ./assets/games/NyctoType/KeyArt.png
- タイトル: NyctoType
- 小見出し: 次回展示: gamescom 2026.8.26~8.30
- ボタン: 詳細
```

## タイトル別アセット

各タイトルごとに、個別ページと同じ `TitleId` のフォルダを作ります。

```text
docs/games/<TitleId>.html
docs/assets/games/<TitleId>/
```

主な画像名は次の形に揃えます。

- `LibraryCapsule.png` - トップページのゲーム一覧で使う縦長画像
- `LibraryHero.png` - 個別ページのヒーロー背景画像
- `KeyArt.png` - トップページのヒーロースライダー用画像
- `ScreenShot01.png` - 個別ページのスクリーンショット
- `ScreenShot02.png` - 個別ページのスクリーンショット
- `OgImage.png` - SNS共有用画像

トップページ上部のヒーロースライダー画像は、`content/hero.md` の `画像` で指定します。タイトルの告知なら `./assets/games/<TitleId>/KeyArt.png` を指定するのが基本です。画像が読み込めない場合は、仮で `docs/assets/studio/placeholder-keyart.svg` を表示します。

現在のヒーロースライダー表示枠は、最も縦長で約 `0.81:1`、最も横長で約 `2.75:1` まで変化します。中央の重要要素を残し、左右上下の端はトリミングされても成立する画像にすると安定します。

## News記事の追加

News一覧ページは `docs/News/index.html` です。
詳細ページは `docs/News/日付_タイトル/index.html` の形で追加します。

例:

```text
docs/News/2026-06-25_サイト準備中/index.html
docs/News/2026-06-25_Steamページ準備中/index.html
```

記事を増やしたら、`docs/News/index.html` とトップページのNews欄にリンクを追加してください。
見た目は `docs/News/news.css` を共通で使います。

## 展示情報の追加

展示、試遊、イベント出展だけをまとめるページは `docs/Exhibitions/index.html` です。
ミュージシャンのサイトのライブ情報一覧のように、日付、イベント名、会場、試遊可能タイトル、リンクをカードとして追加していきます。

## 現在の編集メモ

- サイト内リンクは基本的に同じタブで開きます。
- Steamなどサイト外へ移動する主要リンクは、元サイトを残すために新しいタブで開きます。トップページのSteamリンクには `target="_blank"` と `rel="noopener"` を付けます。
- トップページの対応プラットフォームアイコンは、クリック時にJavaScriptで新しいタブを開きます。
- 各タイトルページのヘッダーには `タイトル一覧` ボタンを置き、`../index.html#games` に戻します。
- 各タイトルページのヒーロー背景は `LibraryHero` を使います。暗幕のグラデーション比率は維持し、暗幕レイヤー全体は `opacity: 0.8` にしています。スキャンラインと下フェードは元のままです。

## 残タスク

- 各タイトルページの `概要` 見出しを、必要に応じて `作品紹介 / About` などに変更します。
- `content/games/<TitleId>.md` と `content/games/OtherLanguage/<TitleId>.<lang>.md` に残っている仮文言を、各タイトルの正式なカード説明、概要、今後の予定、活動記録に差し替えます。
- Android、iOSなどSteam以外のストアURLを本番URLに差し替えます。現状、ReversiのAndroid / iOSは暫定でSteamページへ遷移します。
- トップページのヒーロースライダーに追加するタイトルは、必要に応じて `docs/assets/games/<TitleId>/KeyArt.png` を追加します。
- News記事と展示情報は、実際の公開内容やイベント情報に合わせて追加・更新します。
- GitHub Pages公開後に、PC表示、スマホ表示、外部リンクの新規タブ挙動を確認します。

## ローカル確認

静的サイトなので、`docs/index.html` をブラウザで開くだけでも確認できます。
ローカルサーバーで確認する場合は次のコマンドを使います。

```sh
python3 -m http.server 8000 --directory docs
```
