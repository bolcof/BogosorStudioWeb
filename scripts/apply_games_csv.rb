#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "erb"

ROOT = File.expand_path("..", __dir__)
CSV_PATH = File.join(ROOT, "games.csv")
CONTENT_ROOT = File.join(ROOT, "content")
CONTENT_DIR = File.join(ROOT, "content", "games")
OTHER_LANGUAGE_DIR = File.join(CONTENT_DIR, "OtherLanguage")
HERO_PATH = File.join(CONTENT_ROOT, "hero.md")
HERO_OTHER_LANGUAGE_DIR = File.join(CONTENT_ROOT, "OtherLanguage")
INDEX_PATH = File.join(ROOT, "docs", "index.html")
DEVELOPER_STEAM_URL = "https://store.steampowered.com/developer/BogosorStudio"
CLOUDFLARE_ANALYTICS_SNIPPET = "<!-- Cloudflare Web Analytics --><script defer src='https://static.cloudflareinsights.com/beacon.min.js' data-cf-beacon='{\"token\": \"473f4004c02e4bf596ad36320ecd4c28\"}'></script><!-- End Cloudflare Web Analytics -->"
LANGUAGES = [
  { code: "ja", label: "日本語", html_lang: "ja" },
  { code: "en", label: "English", html_lang: "en" },
  { code: "de", label: "Deutsch", html_lang: "de" },
  { code: "zh-hant", label: "繁體中文", html_lang: "zh-Hant" },
  { code: "zh-hans", label: "简体中文", html_lang: "zh-Hans" },
  { code: "ko", label: "한국어", html_lang: "ko" }
].freeze
LANGUAGE_CODES = LANGUAGES.map { |language| language.fetch(:code) }.freeze

def h(value)
  ERB::Util.html_escape(value.to_s)
end

def asset_file(title_id, preferred)
  dir = File.join(ROOT, "docs", "assets", "games", title_id)
  return preferred if File.exist?(File.join(dir, preferred))

  base = File.basename(preferred, ".*").downcase
  fallback = Dir.children(dir).find { |name| File.basename(name, ".*").downcase == base } if Dir.exist?(dir)
  fallback || preferred
end

def asset_url(title_id, filename)
  path = File.join(ROOT, "docs", "assets", "games", title_id, filename)
  version = File.exist?(path) ? "?v=#{File.mtime(path).to_i}" : ""
  "./assets/games/#{h(title_id)}/#{h(filename)}#{version}"
end

def versioned_doc_asset(path)
  return path unless path.start_with?("./assets/") && !path.include?("?")

  file_path = File.join(ROOT, "docs", path.delete_prefix("./"))
  return path unless File.exist?(file_path)

  "#{path}?v=#{File.mtime(file_path).to_i}"
end

def replace!(html, pattern, replacement, label)
  unless html.sub!(pattern, replacement)
    warn "skip: #{label}"
  end
  html
end

def ensure_analytics_snippet(html)
  return html if html.include?("Cloudflare Web Analytics")

  html.sub(%r{\n\s*</head>}, "\n    #{CLOUDFLARE_ANALYTICS_SNIPPET}\n  </head>")
end

def row_value(row, key, fallback = "")
  value = row[key]
  value.nil? || value.empty? ? fallback : value
end

def attr(value)
  h(value).gsub("\n", "&#10;")
end

def attr_html(value)
  h(value).gsub("\n", "&#10;").gsub('"', "&quot;")
end

def language_key(label)
  normalized = label.to_s.strip.downcase
  return "ja" if ["日本語", "ja", "japanese"].include?(normalized)
  return "en" if ["english", "en", "英語"].include?(normalized)
  return "de" if ["deutsch", "de", "german", "ドイツ語"].include?(normalized)
  return "zh-hant" if ["繁體中文", "繁体字", "zh-hant", "zh", "traditional chinese"].include?(normalized)
  return "zh-hans" if ["简体中文", "簡体中文", "簡体字", "简体字", "zh-hans", "zh-cn", "simplified chinese"].include?(normalized)
  return "ko" if ["한국어", "ko", "korean", "韓国語", "朝鮮語"].include?(normalized)

  nil
end

def section_key(label)
  normalized = label.to_s.strip.downcase
  aliases = {
    "card" => "card",
    "カード" => "card",
    "カード説明" => "card",
    "karte" => "card",
    "卡片" => "card",
    "카드" => "card",
    "summary" => "summary",
    "サマリー" => "summary",
    "短い説明" => "summary",
    "zusammenfassung" => "summary",
    "摘要" => "summary",
    "요약" => "summary",
    "labels" => "labels",
    "label" => "labels",
    "ラベル" => "labels",
    "標籤" => "labels",
    "标签" => "labels",
    "라벨" => "labels",
    "card labels" => "card_labels",
    "card label" => "card_labels",
    "カードラベル" => "card_labels",
    "トップラベル" => "card_labels",
    "kartenlabels" => "card_labels",
    "卡片標籤" => "card_labels",
    "卡片标签" => "card_labels",
    "카드 라벨" => "card_labels",
    "카드라벨" => "card_labels",
    "page labels" => "page_labels",
    "page label" => "page_labels",
    "ページラベル" => "page_labels",
    "タイトルページラベル" => "page_labels",
    "seitenlabels" => "page_labels",
    "頁面標籤" => "page_labels",
    "页面标签" => "page_labels",
    "페이지 라벨" => "page_labels",
    "페이지라벨" => "page_labels",
    "about" => "overview",
    "overview" => "overview",
    "概要" => "overview",
    "über das spiel" => "overview",
    "關於" => "overview",
    "关于" => "overview",
    "遊戲介紹" => "overview",
    "游戏介绍" => "overview",
    "게임 소개" => "overview",
    "게임소개" => "overview",
    "소개" => "overview",
    "plans" => "plans",
    "plan" => "plans",
    "今後の予定" => "plans",
    "予定" => "plans",
    "pläne" => "plans",
    "後續計畫" => "plans",
    "后续计划" => "plans",
    "향후 예정" => "plans",
    "향후예정" => "plans",
    "예정" => "plans",
    "video" => "video",
    "videos" => "video",
    "trailer" => "video",
    "teaser" => "video",
    "movie" => "video",
    "動画" => "video",
    "映像" => "video",
    "影片" => "video",
    "视频" => "video",
    "영상" => "video",
    "trailer video" => "video",
    "teaser video" => "video",
    "history" => "history",
    "活動記録" => "history",
    "公開・出展記録" => "history",
    "出展・更新記録" => "history",
    "verlauf" => "history",
    "aktivitäten" => "history",
    "活動記錄" => "history",
    "活动记录" => "history",
    "활동 기록" => "history",
    "활동기록" => "history",
    "press kit" => "presskit",
    "presskit" => "presskit",
    "press" => "presskit",
    "プレスキット" => "presskit",
    "pressekit" => "presskit",
    "presse-kit" => "presskit",
    "新聞資料包" => "presskit",
    "媒體資料包" => "presskit",
    "新闻资料包" => "presskit",
    "媒体资料包" => "presskit",
    "프레스킷" => "presskit",
    "프레스 키트" => "presskit",
    "links" => "links"
  }
  aliases[normalized]
end

def normalize_markdown_lines(lines)
  lines.join("\n").strip
end

def parse_markdown_sections(path)
  content = {}
  current_section = nil
  buffer = []

  flush = lambda do
    if current_section
      content[current_section] = normalize_markdown_lines(buffer)
    end
    buffer = []
  end

  File.readlines(path, chomp: true).each do |line|
    if (match = line.match(/\A##\s+(.+?)\s*\z/))
      flush.call
      current_section = section_key(match[1])
    elsif !line.match?(/\A#\s+/) && current_section
      buffer << line
    end
  end
  flush.call

  content
end

def parse_legacy_game_markdown(path)
  content = Hash.new { |hash, key| hash[key] = {} }
  current_language = nil
  current_section = nil
  buffer = []

  flush = lambda do
    if current_language && current_section
      content[current_language][current_section] = normalize_markdown_lines(buffer)
    end
    buffer = []
  end

  File.readlines(path, chomp: true).each do |line|
    if (match = line.match(/\A#\s+(.+?)\s*\z/))
      flush.call
      current_language = language_key(match[1])
      current_section = nil
    elsif (match = line.match(/\A##\s+(.+?)\s*\z/))
      flush.call
      current_section = section_key(match[1])
    elsif current_language && current_section
      buffer << line
    end
  end
  flush.call

  content
end

def parse_game_markdown(title_id)
  content = {}

  ja_path = File.join(CONTENT_DIR, "#{title_id}.md")
  ja_split_path = File.join(CONTENT_DIR, "#{title_id}.ja.md")
  if File.exist?(ja_path)
    content["ja"] = parse_markdown_sections(ja_path)
  elsif File.exist?(ja_split_path)
    content["ja"] = parse_markdown_sections(ja_split_path)
  end

  LANGUAGES.reject { |language| language.fetch(:code) == "ja" }.each do |language|
    code = language.fetch(:code)
    path = File.join(OTHER_LANGUAGE_DIR, "#{title_id}.#{code}.md")
    legacy_path = File.join(CONTENT_DIR, "#{title_id}.#{code}.md")
    if File.exist?(path)
      content[code] = parse_markdown_sections(path)
    elsif File.exist?(legacy_path)
      content[code] = parse_markdown_sections(legacy_path)
    end
  end

  if content.empty?
    return warn("skip: missing content #{ja_path}") && {}
  end

  ja_content = content["ja"] || content.values.first || {}
  LANGUAGES.each { |language| content[language.fetch(:code)] ||= ja_content }
  content
end

def hero_field_key(label)
  normalized = label.to_s.strip.downcase
  aliases = {
    "href" => "href",
    "url" => "href",
    "link" => "href",
    "リンク" => "href",
    "連結" => "href",
    "链接" => "href",
    "링크" => "href",
    "image" => "image",
    "key_art" => "image",
    "keyart" => "image",
    "画像" => "image",
    "圖片" => "image",
    "图片" => "image",
    "이미지" => "image",
    "title" => "title",
    "タイトル" => "title",
    "標題" => "title",
    "标题" => "title",
    "제목" => "title",
    "subtitle" => "subtitle",
    "label" => "subtitle",
    "小見出し" => "subtitle",
    "サブタイトル" => "subtitle",
    "untertitel" => "subtitle",
    "副標題" => "subtitle",
    "副标题" => "subtitle",
    "소제목" => "subtitle",
    "부제" => "subtitle",
    "button" => "button",
    "button_label" => "button",
    "ボタン" => "button",
    "按鈕" => "button",
    "按钮" => "button",
    "버튼" => "button"
  }
  aliases[normalized]
end

def parse_hero_markdown(path)
  return [] unless File.exist?(path)

  slides = []
  current = nil

  File.readlines(path, chomp: true).each do |line|
    if (match = line.match(/\A##\s+(.+?)\s*\z/))
      heading = match[1].strip
      id = heading.include?(":") || heading.include?("：") ? heading.split(/[:：]/, 2).last.strip : heading
      current = { "id" => id }
      slides << current
    elsif current && (match = line.match(/\A\s*-?\s*([^:：]+?)\s*[:：]\s*(.+?)\s*\z/))
      key = hero_field_key(match[1])
      current[key] = match[2].strip if key
    end
  end

  slides
end

def hero_slides
  slides_by_language = LANGUAGES.to_h do |language|
    code = language.fetch(:code)
    path = code == "ja" ? HERO_PATH : File.join(HERO_OTHER_LANGUAGE_DIR, "hero.#{code}.md")
    [code, parse_hero_markdown(path)]
  end
  ja_slides = slides_by_language["ja"]
  return [] if ja_slides.empty?

  slides_by_id = slides_by_language.transform_values do |slides|
    slides.to_h { |slide| [slide.fetch("id"), slide] }
  end

  ja_slides.map do |ja_slide|
    id = ja_slide.fetch("id")
    {
      id: id,
      href: ja_slide["href"].to_s.empty? ? "#" : ja_slide["href"],
      image: ja_slide["image"].to_s.empty? ? "./assets/studio/placeholder-keyart.svg" : ja_slide["image"],
      title: LANGUAGES.to_h do |language|
        code = language.fetch(:code)
        slide = slides_by_id.fetch(code, {})[id] || {}
        [code, slide["title"].to_s.empty? ? ja_slide["title"].to_s : slide["title"]]
      end,
      subtitle: LANGUAGES.to_h do |language|
        code = language.fetch(:code)
        slide = slides_by_id.fetch(code, {})[id] || {}
        [code, slide["subtitle"].to_s.empty? ? ja_slide["subtitle"].to_s : slide["subtitle"]]
      end,
      button: LANGUAGES.to_h do |language|
        code = language.fetch(:code)
        slide = slides_by_id.fetch(code, {})[id] || {}
        [code, slide["button"].to_s.empty? ? ja_slide["button"].to_s : slide["button"]]
      end
    }
  end
end

def content_text(content, language, section, fallback = "")
  text = content.dig(language, section).to_s.strip
  text.empty? ? fallback : text
end

def localized_texts(content, section, fallback = "", compact: false)
  ja_text = content_text(content, "ja", section, fallback)
  LANGUAGES.to_h do |language|
    code = language.fetch(:code)
    text = content_text(content, code, section, ja_text)
    [code, compact ? compact_text(text) : text]
  end
end

def localized_attrs(values, html: false)
  prefix = html ? "data-i18n-html" : "data-i18n"
  LANGUAGES.map do |language|
    code = language.fetch(:code)
    value = values[code] || values["ja"] || ""
    "#{prefix}-#{code}=\"#{html ? attr_html(value) : attr(value)}\""
  end.join(" ")
end

def static_attrs(ja:, en:, de:, zh_hant:, zh_hans:, ko:)
  localized_attrs({
    "ja" => ja,
    "en" => en,
    "de" => de,
    "zh-hant" => zh_hant,
    "zh-hans" => zh_hans,
    "ko" => ko
  })
end

def javascript_key(key)
  key.match?(/\A[a-z]+\z/) ? key : key.dump
end

def language_choice_buttons(indent)
  LANGUAGES.map do |language|
    code = language.fetch(:code)
    selected = code == "ja" ? "true" : "false"
    "#{indent}<button class=\"language-choice\" type=\"button\" role=\"option\" data-language-choice=\"#{h(code)}\" aria-selected=\"#{selected}\">#{h(language.fetch(:label))}</button>"
  end.join("\n")
end

def refresh_language_controls(html)
  html = html.gsub(%r{(?<indent>\s*)<div class="language-list" role="listbox" hidden>\n.*?\n\k<indent></div>}m) do
    indent = Regexp.last_match[:indent]
    "#{indent}<div class=\"language-list\" role=\"listbox\" hidden>\n#{language_choice_buttons("#{indent}  ")}\n#{indent}</div>"
  end
  html = html.gsub(
    /const supportedLanguages = \[[^\]]+\];/,
    "const supportedLanguages = [#{LANGUAGE_CODES.map(&:dump).join(", ")}];"
  )
  html = html.gsub(/const languageLabels = \{\n.*?\n[ \t]*\};/m) do |match|
    indent = match[/\A\s*/]
    body = LANGUAGES.map { |language| "#{indent}  #{javascript_key(language.fetch(:code))}: #{language.fetch(:label).dump}," }.join("\n")
    "#{indent}const languageLabels = {\n#{body}\n#{indent}};"
  end
  html = html.gsub(/const htmlLanguageCodes = \{\n.*?\n[ \t]*\};/m) do |match|
    indent = match[/\A\s*/]
    body = LANGUAGES.map { |language| "#{indent}  #{javascript_key(language.fetch(:code))}: #{language.fetch(:html_lang).dump}," }.join("\n")
    "#{indent}const htmlLanguageCodes = {\n#{body}\n#{indent}};"
  end
  html
end

def refresh_static_translations(html)
  replacements = {
    'data-i18n-ja="タイトル一覧" data-i18n-en="Titles" data-i18n-de="Titel" data-i18n-zh-hant="標題列表"' =>
      'data-i18n-ja="タイトル一覧" data-i18n-en="Titles" data-i18n-de="Titel" data-i18n-zh-hant="標題列表" data-i18n-zh-hans="标题列表" data-i18n-ko="타이틀 목록"',
    'data-i18n-ja="ゲーム一覧" data-i18n-en="Games" data-i18n-de="Spiele" data-i18n-zh-hant="遊戲列表"' =>
      'data-i18n-ja="ゲーム一覧" data-i18n-en="Games" data-i18n-de="Spiele" data-i18n-zh-hant="遊戲列表" data-i18n-zh-hans="游戏列表" data-i18n-ko="게임 목록"',
    'data-i18n-ja="日本発の個人ゲームスタジオ" data-i18n-en="Independent game studio from Japan" data-i18n-de="Unabhängiges Spielestudio aus Japan" data-i18n-zh-hant="來自日本的個人遊戲工作室"' =>
      'data-i18n-ja="日本発の個人ゲームスタジオ" data-i18n-en="Independent game studio from Japan" data-i18n-de="Unabhängiges Spielestudio aus Japan" data-i18n-zh-hant="來自日本的個人遊戲工作室" data-i18n-zh-hans="来自日本的个人游戏工作室" data-i18n-ko="일본의 개인 게임 스튜디오"',
    'data-i18n-ja="Steam向けゲームの制作・公開情報を掲載しています。" data-i18n-en="Official information for BogosorStudio games on Steam." data-i18n-de="Offizielle Informationen zu BogosorStudio-Spielen auf Steam." data-i18n-zh-hant="刊載 BogosorStudio Steam 遊戲的製作與公開資訊。"' =>
      'data-i18n-ja="Steam向けゲームの制作・公開情報を掲載しています。" data-i18n-en="Official information for BogosorStudio games on Steam." data-i18n-de="Offizielle Informationen zu BogosorStudio-Spielen auf Steam." data-i18n-zh-hant="刊載 BogosorStudio Steam 遊戲的製作與公開資訊。" data-i18n-zh-hans="发布 BogosorStudio 面向 Steam 的游戏制作与公开信息。" data-i18n-ko="BogosorStudio의 Steam용 게임 제작 및 공개 정보를 게재합니다."',
    'data-i18n-ja="開発タイトル" data-i18n-en="Development Titles" data-i18n-de="Titel in Entwicklung" data-i18n-zh-hant="開發標題"' =>
      'data-i18n-ja="開発タイトル" data-i18n-en="Development Titles" data-i18n-de="Titel in Entwicklung" data-i18n-zh-hant="開發標題" data-i18n-zh-hans="开发标题" data-i18n-ko="개발 타이틀"',
    'data-i18n-ja="公開中・公開予定のタイトル一覧" data-i18n-en="A list of titles released or planned for Steam. Details for each title are linked from its own page." data-i18n-de="Eine Liste der veröffentlichten und geplanten Steam-Titel. Details zu jedem Titel sind über die jeweilige Seite verlinkt." data-i18n-zh-hant="Steam 已公開與預定公開標題列表。各標題的詳細資訊會從個別頁面連結。"' =>
      'data-i18n-ja="公開中・公開予定のタイトル一覧" data-i18n-en="Released and upcoming titles" data-i18n-de="Veröffentlichte und geplante Titel" data-i18n-zh-hant="已公開與預定公開標題列表" data-i18n-zh-hans="已公开与计划公开的标题列表" data-i18n-ko="공개 중 및 공개 예정 타이틀 목록"',
    'data-i18n-ja="更新情報" data-i18n-en="News" data-i18n-de="Neuigkeiten" data-i18n-zh-hant="最新消息"' =>
      'data-i18n-ja="更新情報" data-i18n-en="News" data-i18n-de="Neuigkeiten" data-i18n-zh-hant="最新消息" data-i18n-zh-hans="最新消息" data-i18n-ko="소식"',
    'data-i18n-ja="新作情報、Steamページ公開、イベント出展などの更新先です。" data-i18n-en="Updates for new titles, Steam pages, and event exhibitions." data-i18n-de="Updates zu neuen Titeln, Steam-Seiten und Event-Ausstellungen." data-i18n-zh-hant="新作資訊、Steam 頁面公開與活動展出等更新。"' =>
      'data-i18n-ja="新作情報、Steamページ公開、イベント出展などの更新先です。" data-i18n-en="Updates for new titles, Steam pages, and event exhibitions." data-i18n-de="Updates zu neuen Titeln, Steam-Seiten und Event-Ausstellungen." data-i18n-zh-hant="新作資訊、Steam 頁面公開與活動展出等更新。" data-i18n-zh-hans="新作信息、Steam 页面公开、活动展出等更新。" data-i18n-ko="신작 정보, Steam 페이지 공개, 이벤트 전시 등의 업데이트입니다."',
    'data-i18n-ja="News一覧はこちら（工事中）" data-i18n-en="News list here (under construction)" data-i18n-de="News-Liste hier (im Aufbau)" data-i18n-zh-hant="News 列表在這裡（施工中）"' =>
      'data-i18n-ja="News一覧はこちら（工事中）" data-i18n-en="News list here (under construction)" data-i18n-de="News-Liste hier (im Aufbau)" data-i18n-zh-hant="News 列表在這裡（施工中）" data-i18n-zh-hans="News 列表在这里（建设中）" data-i18n-ko="News 목록은 여기（공사 중）"',
    'data-i18n-ja="展示・試遊情報はこちら（工事中）" data-i18n-en="Exhibition and demo information here (under construction)" data-i18n-de="Ausstellungs- und Demo-Informationen hier (im Aufbau)" data-i18n-zh-hant="展示與試玩資訊在這裡（施工中）"' =>
      'data-i18n-ja="展示・試遊情報はこちら（工事中）" data-i18n-en="Exhibition and demo information here (under construction)" data-i18n-de="Ausstellungs- und Demo-Informationen hier (im Aufbau)" data-i18n-zh-hant="展示與試玩資訊在這裡（施工中）" data-i18n-zh-hans="展示与试玩信息在这里（建设中）" data-i18n-ko="전시・시연 정보는 여기（공사 중）"',
    'data-i18n-ja="Webページ公開" data-i18n-en="Website published" data-i18n-de="Website veröffentlicht" data-i18n-zh-hant="網站公開"' =>
      'data-i18n-ja="Webページ公開" data-i18n-en="Website published" data-i18n-de="Website veröffentlicht" data-i18n-zh-hant="網站公開" data-i18n-zh-hans="网站公开" data-i18n-ko="웹페이지 공개"',
    'data-i18n-ja="BogosorStudioをフォロー" data-i18n-en="Follow BogosorStudio" data-i18n-de="BogosorStudio folgen" data-i18n-zh-hant="追蹤 BogosorStudio"' =>
      'data-i18n-ja="BogosorStudioをフォロー" data-i18n-en="Follow BogosorStudio" data-i18n-de="BogosorStudio folgen" data-i18n-zh-hant="追蹤 BogosorStudio" data-i18n-zh-hans="关注 BogosorStudio" data-i18n-ko="BogosorStudio 팔로우"',
    'data-i18n-ja="ストアページ、開発中の更新、イベント出展情報へのリンクです。" data-i18n-en="Links to store pages, development updates, and event exhibition information." data-i18n-de="Links zu Store-Seiten, Entwicklungsupdates und Event-Ausstellungen." data-i18n-zh-hant="前往商店頁面、開發中更新與活動展出資訊的連結。"' =>
      'data-i18n-ja="ストアページ、開発中の更新、イベント出展情報へのリンクです。" data-i18n-en="Links to store pages, development updates, and event exhibition information." data-i18n-de="Links zu Store-Seiten, Entwicklungsupdates und Event-Ausstellungen." data-i18n-zh-hant="前往商店頁面、開發中更新與活動展出資訊的連結。" data-i18n-zh-hans="通往商店页面、开发中更新与活动展出信息的链接。" data-i18n-ko="스토어 페이지, 개발 업데이트, 이벤트 전시 정보 링크입니다."'
  }

  replacements.each { |before, after| html = html.gsub(/#{Regexp.escape(before)}(?!\s+data-i18n-(?:zh-hans|ko)=)/, after) }
  html = html.gsub('<a class="nav-link" href="./News/index.html">News</a>',
                   '<a class="nav-link" href="./News/index.html" data-i18n-ja="News" data-i18n-en="News" data-i18n-de="News" data-i18n-zh-hant="News" data-i18n-zh-hans="News" data-i18n-ko="뉴스">News</a>')
  html = html.gsub('<a class="nav-link" href="./Exhibitions/index.html">展示情報</a>',
                   '<a class="nav-link" href="./Exhibitions/index.html" data-i18n-ja="展示情報" data-i18n-en="Exhibitions" data-i18n-de="Ausstellungen" data-i18n-zh-hant="展示資訊" data-i18n-zh-hans="展示信息" data-i18n-ko="전시 정보">展示情報</a>')
  html = html.gsub('<a class="nav-link" href="#contact">Contact</a>',
                   '<a class="nav-link" href="#contact" data-i18n-ja="Contact" data-i18n-en="Contact" data-i18n-de="Kontakt" data-i18n-zh-hant="聯絡" data-i18n-zh-hans="联系" data-i18n-ko="문의">Contact</a>')
  html
end

def compact_text(text)
  text.to_s.lines.map(&:strip).reject(&:empty?).join(" ")
end

def markdown_list_items(text)
  lines = text.to_s.gsub(/<!--.*?-->/m, "").lines.map(&:chomp)
  bullet_items = lines.map do |line|
    match = line.match(/\A\s*[-*]\s+(.+?)\s*\z/)
    match && match[1].strip
  end.compact
  return bullet_items unless bullet_items.empty?

  lines.map(&:strip).reject(&:empty?)
end

def split_info_item(text)
  item = text.to_s.strip
  colon_split = item.match(/\A([^\[\]\n]{2,42}?(?:\d{4}|\d{2,4}|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|年|月|日)[^\[\]\n]{0,30}?)[：:]\s+(.+)\z/i)
  return [colon_split[1].strip, colon_split[2].strip] if colon_split

  date_patterns = [
    /\A((?:\d{4}[.\/]\d{1,2}(?:[.\/]\d{1,2})?(?:[-–〜~ー]\d{1,2}(?:[.\/]\d{1,2})?)?)|(?:\d{4}年\d{1,2}月(?:\d{1,2}日)?(?:[-–〜~ー至]\d{1,2}(?:月|日)?(?:\d{1,2}日)?)?))\s+(.+)\z/,
    /\A(\d{4}年\d{1,2}月(?:\d{1,2}日)?)(.+)\z/
  ]

  date_patterns.each do |pattern|
    match = item.match(pattern)
    return [match[1].strip, match[2].strip] if match
  end

  ["", item]
end

def timeline_date_width(items_by_language)
  widths = items_by_language.values.flatten.map do |item|
    split_info_item(item).first.each_char.sum { |char| char.ascii_only? ? 0.58 : 1.0 }
  end
  width = (widths.max || 0).ceil + 0.5
  [[width, 7.5].max, 18].min
end

def timeline_date_width_for_content(content)
  items_by_language = LANGUAGES.to_h do |language|
    code = language.fetch(:code)
    items = markdown_list_items(content_text(content, code, "plans")) +
            markdown_list_items(content_text(content, code, "history"))
    [code, items]
  end
  timeline_date_width(items_by_language)
end

def inline_markdown_to_html(text)
  escaped = h(text)
  escaped.gsub(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/) do
    label = Regexp.last_match(1)
    url = Regexp.last_match(2)
    "<a href=\"#{url}\" target=\"_blank\" rel=\"noopener\">#{label}</a>"
  end
end

def localized_paragraph(content, section, fallback = "", indent: "            ")
  texts = localized_texts(content, section, fallback)
  "#{indent}<p #{localized_attrs(texts)}>#{h(texts.fetch("ja"))}</p>"
end

def presskit_field_key(label)
  return "kicker" if label.to_s.strip.downcase == "kicker"
  normalized = label.to_s.strip.downcase.tr("_", " ")
  aliases = {
    "href" => "href",
    "url" => "href",
    "link" => "href",
    "リンク" => "href",
    "連結" => "href",
    "链接" => "href",
    "링크" => "href",
    "title" => "title",
    "タイトル" => "title",
    "標題" => "title",
    "标题" => "title",
    "제목" => "title",
    "description" => "description",
    "text" => "description",
    "説明" => "description",
    "本文" => "description",
    "說明" => "description",
    "说明" => "description",
    "설명" => "description",
    "본문" => "description",
    "button" => "button",
    "button label" => "button",
    "ボタン" => "button",
    "按鈕" => "button",
    "按钮" => "button",
    "버튼" => "button",
    "password" => "password",
    "パスワード" => "password"
  }
  aliases[normalized]
end

def parse_key_value_section(text, key_method)
  config = {}
  text.to_s.gsub(/<!--.*?-->/m, "").lines.map(&:strip).reject(&:empty?).each do |line|
    line = line.sub(/\A[-*]\s+/, "")
    next unless (match = line.match(/\A([^:：]+)[:：]\s*(.+)\z/))

    key = send(key_method, match[1])
    config[key] = match[2].strip if key
  end
  config
end

def presskit_config(row, content)
  ja_section = content_text(content, "ja", "presskit")
  return nil if ja_section.empty?

  ja_config = parse_key_value_section(ja_section, :presskit_field_key)
  title_id = row.fetch("title_id")
  href = ja_config["href"].to_s.empty? ? "../presskits/#{title_id}/" : ja_config["href"]

  {
    href: href,
    kicker: LANGUAGES.to_h do |language|
      code = language.fetch(:code)
      config = parse_key_value_section(content_text(content, code, "presskit", ja_section), :presskit_field_key)
      defaults = { "ja" => "PRESS", "en" => "PRESS", "de" => "PRESSE", "zh-hant" => "媒體", "zh-hans" => "媒体", "ko" => "프레스" }
      [code, config["kicker"].to_s.empty? ? defaults.fetch(code) : config["kicker"]]
    end,
    title: LANGUAGES.to_h do |language|
      code = language.fetch(:code)
      config = parse_key_value_section(content_text(content, code, "presskit", ja_section), :presskit_field_key)
      [code, config["title"].to_s.empty? ? "Press Kit" : config["title"]]
    end,
    description: LANGUAGES.to_h do |language|
      code = language.fetch(:code)
      config = parse_key_value_section(content_text(content, code, "presskit", ja_section), :presskit_field_key)
      [code, config["description"].to_s]
    end,
    button: LANGUAGES.to_h do |language|
      code = language.fetch(:code)
      config = parse_key_value_section(content_text(content, code, "presskit", ja_section), :presskit_field_key)
      [code, config["button"].to_s.empty? ? "Open" : config["button"]]
    end,
    password: ja_config["password"].to_s
  }
end

def platform_icon_name(platform)
  normalized = platform.to_s.strip.downcase
  return "steam" if normalized == "steam"
  return "android" if normalized == "android"
  return "ios" if normalized == "ios"

  nil
end

def platform_icons(row)
  row.fetch("meta_platform").split(/[|,\/]/).map do |platform|
    name = platform_icon_name(platform)
    next unless name

    label = platform.strip
    "                    <span class=\"platform-icon\" role=\"link\" tabindex=\"0\" aria-label=\"#{h(label)} store\" title=\"#{h(label)}\" data-store-url=\"#{h(row.fetch("steam_url"))}\"><img src=\"./assets/platforms/#{name}.svg\" alt=\"\" /></span>"
  end.compact.join("\n")
end

def parse_label_item(item)
  match = item.to_s.strip.match(/\A\(([^)]+)\)\s*(.+)\z/)
  return { kind: "main", text: item.to_s.strip } unless match

  { kind: match[1].strip.downcase, text: match[2].strip }
end

def label_class(kind, context)
  normalized = kind.to_s.downcase
  if context == :card
    return "release-label is-event" if normalized == "event"
    return "release-label is-released" if normalized == "released"
    return "release-label is-tba" if normalized == "muted" || normalized == "status"

    "release-label"
  else
    return "label label-event" if normalized == "event"
    return "label label-released" if normalized == "released"
    return "label label-muted" if normalized == "muted" || normalized == "status"

    "label"
  end
end

def label_items(content, section)
  items_by_language = LANGUAGES.to_h do |language|
    code = language.fetch(:code)
    [code, markdown_list_items(content_text(content, code, section))]
  end
  base_items = items_by_language["ja"]

  base_items.each_with_index.map do |ja_item, index|
    ja_label = parse_label_item(ja_item)
    {
      kind: ja_label[:kind],
      text: LANGUAGES.to_h do |language|
        code = language.fetch(:code)
        language_items = items_by_language[code]
        item = language_items[index]
        label = item ? parse_label_item(item) : { text: "" }
        [code, label[:text].to_s]
      end
    }
  end
end

def card_labels(content)
  labels = label_items(content, "card_labels")
  return "" if labels.empty?

  html = labels.map do |label|
    "                    <span class=\"#{label_class(label[:kind], :card)}\" #{localized_attrs(label[:text])}>#{h(label[:text].fetch("ja"))}</span>"
  end.join("\n")

  <<~HTML.rstrip
                  <div class="release-labels" aria-label="公開・展示ステータス">
#{html}
                  </div>
  HTML
end

def game_page_status_row(content)
  labels = label_items(content, "page_labels")
  return "" if labels.empty?

  html = labels.map do |label|
    "              <span class=\"#{label_class(label[:kind], :page)}\" #{localized_attrs(label[:text])}>#{h(label[:text].fetch("ja"))}</span>"
  end.join("\n")

  "            <div class=\"status-row\">\n#{html}\n            </div>"
end

def steam_app_id(steam_url)
  steam_url.to_s[%r{/app/(\d+)}, 1]
end

def game_page_hero(row, content)
  title = row.fetch("title")
  steam_url = row.fetch("steam_url")
  summary_texts = localized_texts(content, "summary", title, compact: true)
  steam_link_label = {
    "ja" => "#{title} のSteamページを開く",
    "en" => "Open #{title} on Steam",
    "de" => "#{title} auf Steam öffnen",
    "zh-hant" => "開啟 #{title} 的 Steam 頁面",
    "zh-hans" => "打开 #{title} 的 Steam 页面",
    "ko" => "Steam에서 #{title} 열기"
  }
  steam_link = [
    "          <a class=\"steam-store-link\" href=\"#{h(steam_url)}\" target=\"_blank\" rel=\"noopener\" aria-label=\"#{h(steam_link_label.fetch("ja"))}\">",
    "            <img class=\"steam-store-logo\" src=\"../assets/platforms/steam-logo.svg\" alt=\"Steam\" />",
    "          </a>"
  ].join("\n")

  <<~HTML.rstrip
      <section class="hero">
        <span class="hero-art" aria-hidden="true"></span>
        <div class="wrap hero-grid">
          <div class="hero-copy">
            <h1>#{h(title)}</h1>
            <p class="summary" #{localized_attrs(summary_texts)}>
              #{h(summary_texts.fetch("ja"))}
            </p>
#{game_page_status_row(content)}
          </div>
#{steam_link}
        </div>
      </section>
  HTML
end

def info_list(content, section, date_width)
  items_by_language = LANGUAGES.to_h do |language|
    code = language.fetch(:code)
    [code, markdown_list_items(content_text(content, code, section))]
  end
  ja_items = items_by_language["ja"]

  return "" if ja_items.empty?

  items = ja_items.each_with_index.map do |ja_item, index|
    ja_date, = split_info_item(ja_item)
    full_body = ja_date.empty?
    date_values = {}
    body_values = {}
    LANGUAGES.each do |language|
      code = language.fetch(:code)
      language_items = items_by_language[code]
      item = language_items[index] || language_items.first || ja_item
      if full_body
        date_values[code] = ""
        body_values[code] = inline_markdown_to_html(item)
      else
        date, body = split_info_item(item)
        date_values[code] = date
        body_values[code] = inline_markdown_to_html(body)
      end
    end
    item_class = full_body ? "timeline-item timeline-item-full" : "timeline-item"
    body_class = full_body ? "info-body info-body-full" : "info-body"
    <<~HTML.rstrip
              <li class="#{item_class}">
                <span class="timeline-dot" aria-hidden="true"></span>
                <span class="info-date" #{localized_attrs(date_values)}>#{h(date_values.fetch("ja"))}</span>
                <span class="#{body_class}" #{localized_attrs(body_values, html: true)}>#{body_values.fetch("ja")}</span>
              </li>
    HTML
  end.join("\n")

  <<~HTML.rstrip
            <ul class="info-list timeline-list timeline-list-#{section}" style="--timeline-date-width: #{date_width}em;">
#{items}
            </ul>
  HTML
end

def overview_section(content)
  <<~HTML.rstrip
      <section class="text-band">
        <div class="wrap text-blocks">
          <article class="text-block">
            <h2 #{static_attrs(ja: "概要", en: "About", de: "Über das Spiel", zh_hant: "遊戲介紹", zh_hans: "游戏介绍", ko: "게임 소개")}>概要</h2>
#{localized_paragraph(content, "overview")}
          </article>
        </div>
      </section>
  HTML
end

def presskit_section(row, content)
  config = presskit_config(row, content)
  return "" unless config

  password = config.fetch(:password)
  protected = !password.empty?
  link_attributes = if protected
                      "href=\"#{h(config.fetch(:href))}\" data-protected-pitch-link data-protected-href=\"#{h(config.fetch(:href))}\""
                    else
                      "href=\"#{h(config.fetch(:href))}\""
                    end
  password_dialog = if protected
                      <<~HTML.rstrip
          <dialog class="pitch-password-dialog" data-pitch-password-dialog aria-labelledby="pitch-password-title">
            <form class="pitch-password-form" data-pitch-password-form>
              <h2 id="pitch-password-title" #{static_attrs(ja: "パスワードを入力", en: "Enter password", de: "Passwort eingeben", zh_hant: "輸入密碼", zh_hans: "输入密码", ko: "비밀번호 입력")}>パスワードを入力</h2>
              <p class="pitch-password-description" #{static_attrs(ja: "ピッチデッキを開くにはパスワードが必要です。", en: "A password is required to open the pitch deck.", de: "Zum Öffnen des Pitch Decks ist ein Passwort erforderlich.", zh_hant: "開啟企劃簡報需要密碼。", zh_hans: "打开企划简报需要密码。", ko: "피치 덱을 열려면 비밀번호가 필요합니다.")}>ピッチデッキを開くにはパスワードが必要です。</p>
              <label for="pitch-password-input" #{static_attrs(ja: "パスワード", en: "Password", de: "Passwort", zh_hant: "密碼", zh_hans: "密码", ko: "비밀번호")}>パスワード</label>
              <input id="pitch-password-input" type="password" autocomplete="current-password" required data-pitch-password-input />
              <p class="pitch-password-error" role="alert" hidden data-pitch-password-error #{static_attrs(ja: "パスワードが違います。このページに戻ります。", en: "Incorrect password. Returning to this page.", de: "Falsches Passwort. Sie kehren zu dieser Seite zurück.", zh_hant: "密碼錯誤。將返回此頁面。", zh_hans: "密码错误。将返回此页面。", ko: "비밀번호가 올바르지 않습니다. 이 페이지로 돌아갑니다.")}>パスワードが違います。このページに戻ります。</p>
              <div class="pitch-password-actions">
                <button type="button" class="pitch-password-cancel" data-pitch-password-cancel #{static_attrs(ja: "キャンセル", en: "Cancel", de: "Abbrechen", zh_hant: "取消", zh_hans: "取消", ko: "취소")}>キャンセル</button>
                <button type="submit" class="pitch-password-submit" #{static_attrs(ja: "開く", en: "Open", de: "Öffnen", zh_hant: "開啟", zh_hans: "打开", ko: "열기")}>開く</button>
              </div>
            </form>
          </dialog>
          <script>
            (() => {
              const link = document.querySelector("[data-protected-pitch-link]");
              const dialog = document.querySelector("[data-pitch-password-dialog]");
              const form = dialog?.querySelector("[data-pitch-password-form]");
              const input = dialog?.querySelector("[data-pitch-password-input]");
              const error = dialog?.querySelector("[data-pitch-password-error]");
              const cancel = dialog?.querySelector("[data-pitch-password-cancel]");
              if (!link || !dialog || !form || !input || !error || !cancel) throw new Error("Pitch password dialog is incomplete");

              const resetDialog = () => {
                form.reset();
                error.hidden = true;
              };

              link.addEventListener("click", (event) => {
                event.preventDefault();
                resetDialog();
                dialog.showModal();
                input.focus();
              });
              cancel.addEventListener("click", () => dialog.close());
              dialog.addEventListener("click", (event) => {
                if (event.target === dialog) dialog.close();
              });
              dialog.addEventListener("close", resetDialog);
              form.addEventListener("submit", (event) => {
                event.preventDefault();
                if (input.value === #{password.inspect}) {
                  window.location.assign(link.dataset.protectedHref);
                  return;
                }
                error.hidden = false;
                input.disabled = true;
                window.setTimeout(() => {
                  input.disabled = false;
                  dialog.close();
                }, 1300);
              });
            })();
          </script>
                      HTML
                    else
                      ""
                    end

  <<~HTML.rstrip
      <section class="text-band presskit-band">
        <div class="wrap">
          <a class="presskit-panel" #{link_attributes}>
            <span class="presskit-kicker" #{localized_attrs(config.fetch(:kicker))}>#{h(config.fetch(:kicker).fetch("ja"))}</span>
            <span class="presskit-title" #{localized_attrs(config.fetch(:title))}>#{h(config.fetch(:title).fetch("ja"))}</span>
            <span class="presskit-description" #{localized_attrs(config.fetch(:description))}>#{h(config.fetch(:description).fetch("ja"))}</span>
            <span class="presskit-button" #{localized_attrs(config.fetch(:button))}>#{h(config.fetch(:button).fetch("ja"))}</span>
          </a>
        </div>
#{password_dialog}
      </section>
  HTML
end

def timeline_text_section(content)
  timeline_date_width = timeline_date_width_for_content(content)
  plans = info_list(content, "plans", timeline_date_width)
  history = info_list(content, "history", timeline_date_width)
  plans_section = if plans.empty?
                    ""
                  else
                    <<~HTML.rstrip
          <article class="text-block">
            <h2 #{static_attrs(ja: "今後の予定", en: "Plans", de: "Pläne", zh_hant: "後續計畫", zh_hans: "后续计划", ko: "향후 예정")}>今後の予定</h2>
#{plans}
          </article>
                    HTML
                  end
  history_section = if history.empty?
                      ""
                    else
                      <<~HTML.rstrip
          <article class="text-block">
            <h2 #{static_attrs(ja: "活動記録", en: "History", de: "Aktivitäten", zh_hant: "活動記錄", zh_hans: "活动记录", ko: "활동 기록")}>活動記録</h2>
#{history}
          </article>
                      HTML
                    end
  return "" if plans_section.empty? && history_section.empty?

  <<~HTML.rstrip
      <section class="text-band">
        <div class="wrap text-blocks">
#{plans_section}
#{history_section}
        </div>
      </section>
  HTML
end

def video_field_key(label)
  normalized = label.to_s.strip.downcase.tr("_", " ")
  aliases = {
    "youtube" => "youtube",
    "youtube url" => "youtube",
    "file" => "file",
    "video" => "file",
    "movie" => "file",
    "src" => "file",
    "url" => "url",
    "poster" => "poster",
    "title" => "title",
    "caption" => "caption"
  }
  aliases[normalized]
end

def video_config(content)
  text = content_text(content, "ja", "video")
  return nil if text.empty?

  config = {}
  text.lines.map(&:strip).reject(&:empty?).each do |line|
    line = line.sub(/\A[-*]\s+/, "")
    if (match = line.match(/\A([^:：]+)[:：]\s*(.+)\z/))
      key = video_field_key(match[1])
      config[key] = match[2].strip if key
    elsif line.match?(%r{\Ahttps?://})
      key = line.match?(%r{(?:youtube\.com|youtu\.be)}) ? "youtube" : "url"
      config[key] ||= line
    end
  end

  src = config["youtube"] || config["file"] || config["url"]
  return nil unless src

  type = src.match?(%r{(?:youtube\.com|youtu\.be)}) ? "youtube" : "file"
  config.merge("src" => src, "type" => type)
end

def youtube_embed_url(url)
  id = url[%r{youtu\.be/([^?&#/]+)}, 1] ||
       url[%r{youtube\.com/watch\?v=([^?&#/]+)}, 1] ||
       url[%r{youtube\.com/embed/([^?&#/]+)}, 1] ||
       url[%r{youtube\.com/shorts/([^?&#/]+)}, 1]
  id ? "https://www.youtube-nocookie.com/embed/#{id}" : url
end

def video_mime_type(path)
  case File.extname(path).downcase
  when ".webm"
    "video/webm"
  when ".mov"
    "video/quicktime"
  else
    "video/mp4"
  end
end

def video_section(content)
  video = video_config(content)
  return "" unless video

  title = video["title"] || "Teaser Video"
  media = if video.fetch("type") == "youtube"
            <<~HTML.rstrip
              <iframe src="#{h(youtube_embed_url(video.fetch("src")))}" title="#{h(title)}" loading="lazy" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
            HTML
          else
            src = versioned_doc_asset(video.fetch("src"))
            poster = video["poster"] ? " poster=\"#{h(versioned_doc_asset(video["poster"]))}\"" : ""
            <<~HTML.rstrip
              <video controls preload="metadata"#{poster}>
                <source src="#{h(src)}" type="#{video_mime_type(src)}" />
              </video>
            HTML
          end

  <<~HTML.rstrip
      <section class="video-band">
        <div class="wrap">
          <div class="band-head">
            <h2 #{static_attrs(ja: "動画", en: "Video", de: "Video", zh_hant: "影片", zh_hans: "视频", ko: "영상")}>動画</h2>
          </div>
          <div class="teaser-frame">
#{media}
          </div>
        </div>
      </section>
  HTML
end

def detail_sections(row, content, visual_section)
  sections = [overview_section(content)]
  presskit = presskit_section(row, content)
  video = video_section(content)
  timelines = timeline_text_section(content)

  sections << presskit unless presskit.empty?

  if video.empty?
    sections << visual_section unless visual_section.to_s.empty?
    sections << timelines unless timelines.empty?
  else
    sections << video
    sections << timelines unless timelines.empty?
    sections << visual_section unless visual_section.to_s.empty?
  end

  sections.join("\n\n")
end

def text_section(content)
  timeline_date_width = timeline_date_width_for_content(content)
  plans = info_list(content, "plans", timeline_date_width)
  history = info_list(content, "history", timeline_date_width)
  plans_section = if plans.empty?
                    ""
                  else
                    <<~HTML.rstrip
          <article class="text-block">
            <h2 #{static_attrs(ja: "今後の予定", en: "Plans", de: "Pläne", zh_hant: "後續計畫", zh_hans: "后续计划", ko: "향후 예정")}>今後の予定</h2>
#{plans}
          </article>
                    HTML
                  end
  history_section = if history.empty?
                      ""
                    else
                      <<~HTML.rstrip
          <article class="text-block">
            <h2 #{static_attrs(ja: "活動記録", en: "History", de: "Aktivitäten", zh_hant: "活動記錄", zh_hans: "活动记录", ko: "활동 기록")}>活動記録</h2>
#{history}
          </article>
                      HTML
                    end

  <<~HTML.rstrip
      <section class="text-band">
        <div class="wrap text-blocks">
          <article class="text-block">
            <h2 #{static_attrs(ja: "概要", en: "About", de: "Über das Spiel", zh_hant: "遊戲介紹", zh_hans: "游戏介绍", ko: "게임 소개")}>概要</h2>
#{localized_paragraph(content, "overview")}
          </article>
#{plans_section}
#{history_section}
        </div>
      </section>
  HTML
end

def game_card(row, content)
  title_id = row.fetch("title_id")
  capsule = asset_file(title_id, "LibraryCapsule.png")
  platforms = platform_icons(row)
  labels = card_labels(content)
  card_texts = localized_texts(content, "card", row.fetch("title"), compact: true)

  <<~HTML.rstrip
              <a
                class="capsule-card"
                href="./games/#{h(title_id)}.html"
                style="--capsule-art: url('#{asset_url(title_id, capsule)}')"
              >
                <div class="capsule-content">
                  <div class="platform-row" aria-label="対応プラットフォーム">
#{platforms}
                  </div>
#{labels}
                  <h3>#{h(row.fetch("title"))}</h3>
                  <p #{localized_attrs(card_texts)}>#{h(card_texts.fetch("ja"))}</p>
                </div>
              </a>
  HTML
end

def hero_slide(slide, active: false)
  image = versioned_doc_asset(slide.fetch(:image))

  <<~HTML.rstrip
            <a
              class="hero-slide#{active ? " is-active" : ""}"
              href="#{h(slide.fetch(:href))}"
              data-key-art="#{h(image)}"
              style="--slide-art: url('#{h(image)}')"
            >
              <div class="slide-panel">
                <div>
                  <p #{localized_attrs(slide.fetch(:subtitle))}>#{h(slide.fetch(:subtitle).fetch("ja"))}</p>
                  <strong #{localized_attrs(slide.fetch(:title))}>#{h(slide.fetch(:title).fetch("ja"))}</strong>
                </div>
                <span class="button button-secondary" #{localized_attrs(slide.fetch(:button))}>#{h(slide.fetch(:button).fetch("ja"))}</span>
              </div>
            </a>
  HTML
end

def hero_media
  hero_items = hero_slides
  slides = hero_items.each_with_index.map do |slide, index|
    hero_slide(slide, active: index.zero?)
  end

  dot_labels = hero_items.map do |slide|
    "              <button class=\"slide-dot\" type=\"button\" aria-label=\"#{h(slide.fetch(:title).fetch("ja"))}を表示\"></button>"
  end
  dot_labels[0] = dot_labels[0].sub("slide-dot", "slide-dot is-active") if dot_labels[0]

  <<~HTML.rstrip
          <div class="hero-media" aria-label="注目情報スライドショー">
#{slides.join("\n\n")}

            <div class="slide-dots" aria-label="スライド切り替え">
#{dot_labels.join("\n")}
            </div>
          </div>
  HTML
end

def update_index(rows, contents)
  html = File.read(INDEX_PATH)
  cards = rows.map { |row| game_card(row, contents.fetch(row.fetch("title_id"), {})) }.join("\n\n")
  html = replace!(
    html,
    /          <div class="hero-media" aria-label="注目情報スライドショー">\n.*?\n          <\/div>\n        <\/section>/m,
    "#{hero_media}\n        </section>",
    "index hero media"
  )
  html = replace!(
    html,
    /            <div class="capsule-shelf" aria-label="Steamライブラリーカプセル">\n.*?\n            <\/div>/m,
    "            <div class=\"capsule-shelf\" aria-label=\"Steamライブラリーカプセル\">\n#{cards}\n            </div>",
    "index capsule shelf"
  )
  html = refresh_static_translations(refresh_language_controls(html))
  html = ensure_analytics_snippet(html)
  File.write(INDEX_PATH, html)
end

def update_game_page(row, content)
  title_id = row.fetch("title_id")
  path = File.join(ROOT, "docs", "games", "#{title_id}.html")
  return warn("skip: missing page #{path}") unless File.exist?(path)

  title = row.fetch("title")
  steam_url = row.fetch("steam_url")
  x_url = row.fetch("x_url")
  html = File.read(path)
  visual_section = html[%r{      <section class="visual-band">\n.*?\n      </section>}m].to_s

  html = replace!(html, /content="[^"]+ の紹介ページ。Steamページ、更新情報、関連リンクを掲載しています。"/, "content=\"#{h(title)} の紹介ページ。Steamページ、更新情報、関連リンクを掲載しています。\"", "#{title_id} meta description")
  html = replace!(html, /<meta property="og:title" content="[^"]+ \| BogosorStudio" \/>/, "<meta property=\"og:title\" content=\"#{h(title)} | BogosorStudio\" />", "#{title_id} og title")
  html = replace!(html, /content="[^"]+ の紹介ページ。"\n    \/>/, "content=\"#{h(title)} の紹介ページ。\"\n    />", "#{title_id} og description")
  html = replace!(html, /<title>.*? \| BogosorStudio<\/title>/, "<title>#{h(title)} | BogosorStudio</title>", "#{title_id} title")
  html = html.gsub(/https:\/\/store\.steampowered\.com\/(?:search\/\?term=|app\/)[^"]+/, h(steam_url))
  html = html.gsub(/(<a\s+class="button button-primary"\s+href="https:\/\/store\.steampowered\.com\/[^"]+")(?!\s+target=)/, "\\1 target=\"_blank\" rel=\"noopener\"")
  html = html.gsub(/https:\/\/x\.com\/BogosorGames/, h(x_url))
  html = replace!(
    html,
    /      <section class="hero">\n.*?\n      <\/section>/m,
    game_page_hero(row, content),
    "#{title_id} hero"
  )
  html = replace!(
    html,
    /(<nav class="top-links" aria-label="ページリンク">.*?<a\s+class="button button-primary"\s+href=")[^"]+(" target="_blank" rel="noopener"\s*>\s*Steam\s*<\/a>)/m,
    "\\1#{h(DEVELOPER_STEAM_URL)}\\2",
    "#{title_id} header steam link"
  )
  html = replace!(
    html,
    /      <section class="text-band">\n.*?\n      <\/section>(?:\n\n[ \t]*<section class="text-band presskit-band">\n.*?\n[ \t]*<\/section>)?(?:\n\n      <section class="video-band">\n.*?\n      <\/section>)?(?:\n\n      <section class="visual-band">\n.*?\n      <\/section>)?(?:\n\n      <section class="text-band">\n.*?\n      <\/section>)?/m,
    detail_sections(row, content, visual_section),
    "#{title_id} detail sections"
  )
  html.gsub!(/\n?\s*<section class="link-panel">\n.*?\n\s*<\/section>/m, "")
  html = html.gsub(/alt="[^"]+ screenshot ([0-9]{2})"/, "alt=\"#{h(title)} screenshot \\1\"")
  html = refresh_static_translations(refresh_language_controls(html))
  html = ensure_analytics_snippet(html)

  File.write(path, html)
end

rows = CSV.read(CSV_PATH, headers: true, encoding: "bom|utf-8").map(&:to_h)
contents = rows.to_h { |row| [row.fetch("title_id"), parse_game_markdown(row.fetch("title_id"))] }
update_index(rows, contents)
rows.each { |row| update_game_page(row, contents.fetch(row.fetch("title_id"), {})) }

puts "Applied #{rows.length} games from games.csv"
