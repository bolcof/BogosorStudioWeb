# Sak Winik Web / Redirect 引き継ぎ

最終更新: 2026-06-22

## 目的

Steamストアページ公開前は準備中ページへ、公開後はSteamストアページへ飛ぶ固定URLを運用する。

ユーザーに配るURLは Short.io の短縮リンクに集約し、リンク先だけを後から差し替える。

## 現在の公開構成

- GitHub repository: `https://github.com/bolcof/SakWinik`
- GitHub Pages URL: `https://bolcof.github.io/SakWinik/`
- Short.io domain: `sakwinik.s.gy`
- Short.io の現在の向き先: `https://bolcof.github.io/SakWinik/`
- Steam公開後の作業: Short.io 側の destination URL を Steam ストアページに差し替える

## GitHub Pages 設定

GitHub repository settings:

- Source: `Deploy from a branch`
- Branch: `main`
- Folder: `/docs`

GitHub Pages の公開対象は `/docs` 配下のみ。
リポジトリが private の場合でも Pages の公開サイトは public になる。これは仕様で、公開されるのは `/docs` のWebページだけ。

## ファイル構成

```text
docs/
├── index.html              # GitHub Pagesで実際に公開されるページ
└── SakWinikLogo2.png       # タイトル部分のロゴ画像

web/
└── coming_soon.html        # 初期版。現状はdocs/index.htmlが最新・正と考える
```

注意:

- `docs/index.html` が現在の公開版。
- `web/coming_soon.html` は初期作成時の元ファイルで、ロゴ差し替え・差し色変更は `docs/index.html` 側に反映済み。
- 今後編集するなら、基本は `docs/index.html` を編集する。

## 現在のデザイン仕様

- ページタイトル: `Sak Winik: The Appointed One`
- タイトル表示: テキストではなく `SakWinikLogo2.png`
- 差し色: ゴールド `#D4A830`
- 背景: ダークSF調
- 演出:
  - グリッド背景
  - スキャンラインアニメーション
  - `Steam release in preparation` のパルスバッジ
- 表示リンク:
  - X: `https://x.com/BogosorGames`

## 現在のHTML本文

```text
Prove you are human — to an AI.
A tense, single-session conversation game set in the near future.
```

必要なら今後、BitSummit/Steam向けコピーに合わせて差し替える。

## 直近で実施済みの作業

1. `web/coming_soon.html` を `docs/index.html` として配置
2. GitHub Pages の `/docs` 公開用に push
3. repository 名を `AiWerewolf` から `SakWinik` に変更
4. local remote を `https://github.com/bolcof/SakWinik.git` に変更
5. `.claude/worktrees/quizzical-hypatia` がサブモジュール扱いでPagesビルドを落としていたため、git管理から削除
6. `.claude/worktrees/` を `.gitignore` に追加
7. ロゴ画像 `SakWinikLogo2.png` を `docs/` に追加
8. ページのアクセントカラーを青緑からゴールドに変更

関連コミット:

- `48b8a0c` Add GitHub Pages coming soon page (docs/index.html)
- `d68d00a` Fix GitHub Pages build: remove .claude/worktrees submodule, add to .gitignore
- `904681e` Update coming soon page: logo image + gold accent color

## Short.io 運用

Short.io では、配布用の短縮URLを1本作る。

現在:

```text
Short.io URL -> https://bolcof.github.io/SakWinik/
```

Steam公開後:

```text
Short.io URL -> Steam store page URL
```

Short.io のURL自体は変えない。SNS、DM、ポストカード、展示物にはShort.io側のURLを載せる。

## 注意点

- GitHub Pages の Custom domain 欄には `sakwinik` などを入れない。GitHub Pages側のカスタムドメインは不要。
- Short.io 側でリダイレクト管理する。
- GitHub Pages のURLは `https://bolcof.github.io/SakWinik/`。
- リポジトリ名を変えると GitHub Pages URL も変わるので、今後は repository 名を変更しない方がよい。
- `Research.md` がローカルで削除状態になっているが、このWeb作業とは無関係。勝手に戻さない。

## 次にやる可能性があること

- `docs/index.html` の本文を最新コピーに差し替える
- ロゴサイズやモバイル表示を確認して微調整する
- Short.io の destination URL が `https://bolcof.github.io/SakWinik/` になっているか確認する
- Steamページ公開後、Short.io の destination URL を Steam URL に差し替える

