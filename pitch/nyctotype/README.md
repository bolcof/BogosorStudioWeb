# NyctoType Web Pitch

パートナー向けピッチの日英版。2026-09-09から編集元をBogosorStudioWebの `pitch/nyctotype/` に移しました。以後はこのフォルダを正本とし、NyctoTypeリポジトリ側は移設時点の保存版です。

編集の経緯、文章の方針、承認済みの内容は [引き継ぎ文書](../../NyctoType_Pitch_Handoff.md) を先に確認してください。元Figmaの文章を基本とし、大きな削除や要約はユーザーに相談します。

## 編集するファイル

- `app/page.tsx`: 全体構成と本文の承認済み修正。
- `app/schedule-section.tsx`: スケジュール。ユーザーの直接編集も含みます。
- `app/esports-section.tsx` / `app/progress-section.tsx`: 競技性の図と説明、活動歴と紹介記事。
- `app/english-copy.json`: 日本語に対応する英訳。本文と一緒に更新します。
- `app/globals.css`: レイアウト。PDFよりWebの見やすさを優先します。
- `app/image-slots.ts` / `public/images/`: 画像設定と素材。章番号とIMAGE番号は別です。
- `app/update-history.json`: 公開履歴。現在は2026-09-09「ピッチ資料を公開しました。」のみ。編集ログを自動追加しません。
- `app/original-deck.json` / `app/deck-data.json`: 元Figma・旧編集版のスナップショット。原則変更しません。
- `原文復元メモ.md` / `画像準備リスト.md`: 過去の経緯と素材の出所。古い配置や作業時点の記述を含むので、現在の手順はこのREADMEと引き継ぎ文書を優先します。

## 生成とサイトへの反映

Node.js 22.13以上、pnpm、Python 3が必要です。Python側は標準ライブラリのみ使用します。

初回はこのフォルダで依存関係をインストールします。

```sh
pnpm install --frozen-lockfile
```

サイトのリポジトリ直下から次を実行します。作業ディレクトリに依存せず、スクリプト自身の場所からパスを解決します。

```sh
node pitch/nyctotype/scripts/update-site.mjs
```

ビルド、単体HTMLの生成、本文・翻訳・日英切り替えの検証を順に行い、全て成功した場合だけ `docs/pitchdecks/NyctoType/index.html` を更新します。Pythonの場所は環境変数 `PYTHON` で指定できます。プッシュや外部公開は行いません。

中間生成物は `output/html/NyctoType-Pitch.html` です。`output/`、`dist/`、`node_modules/` はGit対象外。Gitには編集元とサイト用HTMLをまとめて、日本語の説明でコミットします。

NyctoTypeプロジェクトの参照、Figmaへの接続、メールへの接続は生成に不要です。掲載用素材はこのフォルダに同梱しています。未選択のメール写真や元スクリーンショットの候補、過去の短縮版/PDFはゲーム側に保存したままで、自動公開しません。

## 公開範囲

掲載HTMLは画像・日英切り替えを内包します。YouTube埋め込みのみネット接続が必要です。ローカルファイルでは動画にエラー153が出る場合があります。

GitHub Pagesの公開対象は従来どおり `docs/`。ただし公開リポジトリへプッシュすればソースやこの文書も閲覧可能です。ピッチにアクセス制限はなく、物語の核心や販売計画も含むため、公開は別途確認してください。旧Sitesの設定 `.openai/` は移設していません。
