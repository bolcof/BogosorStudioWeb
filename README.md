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

タイトル名、タグ、ステータス表示、短い紹介文、Steam / X のリンクなどは、リポジトリ直下の `games.csv` で編集します。

CSVを編集したあと、次のコマンドを実行してください。

```sh
ruby scripts/apply_games_csv.rb
```

このコマンドで、次のHTMLに内容が反映されます。

- `docs/index.html`
- `docs/games/<TitleId>.html`

## タイトル別アセット

各タイトルごとに、個別ページと同じ `TitleId` のフォルダを作ります。

```text
docs/games/<TitleId>.html
docs/assets/games/<TitleId>/
```

主な画像名は次の形に揃えます。

- `LibraryCapsule.png` - トップページのゲーム一覧で使う縦長画像
- `LibraryHero.png` - 個別ページのヒーロー背景画像
- `KeyArt.png` - 個別ページ用の大きな背景画像
- `ScreenShot01.png` - 個別ページのスクリーンショット
- `ScreenShot02.png` - 個別ページのスクリーンショット
- `OgImage.png` - SNS共有用画像

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

## ローカル確認

静的サイトなので、`docs/index.html` をブラウザで開くだけでも確認できます。
ローカルサーバーで確認する場合は次のコマンドを使います。

```sh
python3 -m http.server 8000 --directory docs
```
