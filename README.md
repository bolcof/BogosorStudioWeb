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
`games.csv` はExcelで文字化けしにくいように、UTF-8 BOM付きで保存しています。
見やすいExcelファイルとして `games.xlsx` も置いています。
トップページのカードに表示する対応プラットフォームは `meta_platform` で編集します。
複数ある場合は `Steam|Android|iOS` のように `|` 区切りで書きます。

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

トップページ上部のヒーロースライダーは、各タイトルの `KeyArt.png` を優先して使います。まだ `KeyArt.png` がないタイトルは、仮で `docs/assets/studio/placeholder-keyart.svg` を使います。スライドに `data-key-art="./assets/games/<TitleId>/KeyArt.png"` を入れておくと、後から画像を追加した時に自動で差し替わります。

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

## ローカル確認

静的サイトなので、`docs/index.html` をブラウザで開くだけでも確認できます。
ローカルサーバーで確認する場合は次のコマンドを使います。

```sh
python3 -m http.server 8000 --directory docs
```
