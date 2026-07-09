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
LANGUAGES = [
  { code: "ja", label: "日本語", html_lang: "ja" },
  { code: "en", label: "English", html_lang: "en" },
  { code: "de", label: "Deutsch", html_lang: "de" },
  { code: "zh-hant", label: "繁體中文", html_lang: "zh-Hant" }
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
    "summary" => "summary",
    "サマリー" => "summary",
    "短い説明" => "summary",
    "zusammenfassung" => "summary",
    "摘要" => "summary",
    "labels" => "labels",
    "label" => "labels",
    "ラベル" => "labels",
    "標籤" => "labels",
    "card labels" => "card_labels",
    "card label" => "card_labels",
    "カードラベル" => "card_labels",
    "トップラベル" => "card_labels",
    "kartenlabels" => "card_labels",
    "卡片標籤" => "card_labels",
    "page labels" => "page_labels",
    "page label" => "page_labels",
    "ページラベル" => "page_labels",
    "タイトルページラベル" => "page_labels",
    "seitenlabels" => "page_labels",
    "頁面標籤" => "page_labels",
    "about" => "overview",
    "overview" => "overview",
    "概要" => "overview",
    "über das spiel" => "overview",
    "關於" => "overview",
    "遊戲介紹" => "overview",
    "plans" => "plans",
    "plan" => "plans",
    "今後の予定" => "plans",
    "予定" => "plans",
    "pläne" => "plans",
    "後續計畫" => "plans",
    "history" => "history",
    "活動記録" => "history",
    "公開・出展記録" => "history",
    "出展・更新記録" => "history",
    "verlauf" => "history",
    "aktivitäten" => "history",
    "活動記錄" => "history",
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
    "image" => "image",
    "key_art" => "image",
    "keyart" => "image",
    "画像" => "image",
    "圖片" => "image",
    "title" => "title",
    "タイトル" => "title",
    "標題" => "title",
    "subtitle" => "subtitle",
    "label" => "subtitle",
    "小見出し" => "subtitle",
    "サブタイトル" => "subtitle",
    "untertitel" => "subtitle",
    "副標題" => "subtitle",
    "button" => "button",
    "button_label" => "button",
    "ボタン" => "button",
    "按鈕" => "button"
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

def static_attrs(ja:, en:, de:, zh_hant:)
  localized_attrs({
    "ja" => ja,
    "en" => en,
    "de" => de,
    "zh-hant" => zh_hant
  })
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
  base_items = items_by_language.values.find { |items| !items.empty? } || []

  base_items.each_with_index.map do |ja_item, index|
    ja_label = parse_label_item(ja_item)
    {
      kind: ja_label[:kind],
      text: LANGUAGES.to_h do |language|
        code = language.fetch(:code)
        language_items = items_by_language[code]
        label = parse_label_item(language_items[index] || language_items.first || ja_label[:text])
        [code, label[:text]]
      end
    }
  end
end

def card_labels(content)
  labels = label_items(content, "card_labels")
  labels = label_items(content, "labels").reject { |label| ["muted", "status"].include?(label[:kind]) } if labels.empty?
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
  labels = label_items(content, "labels") if labels.empty?
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
    "zh-hant" => "開啟 #{title} 的 Steam 頁面"
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
    date_values = {}
    body_values = {}
    LANGUAGES.each do |language|
      code = language.fetch(:code)
      language_items = items_by_language[code]
      item = language_items[index] || language_items.first || ja_item
      date, body = split_info_item(item)
      date_values[code] = date
      body_values[code] = inline_markdown_to_html(body)
    end
    body_class = date_values.fetch("ja").empty? ? "info-body info-body-full" : "info-body"
    <<~HTML.rstrip
              <li class="timeline-item">
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

def text_section(content)
  timeline_date_width = timeline_date_width_for_content(content)
  plans = info_list(content, "plans", timeline_date_width)
  history = info_list(content, "history", timeline_date_width)
  plans_section = if plans.empty?
                    ""
                  else
                    <<~HTML.rstrip
          <article class="text-block">
            <h2 #{static_attrs(ja: "今後の予定", en: "Plans", de: "Pläne", zh_hant: "後續計畫")}>今後の予定</h2>
#{plans}
          </article>
                    HTML
                  end
  history_section = if history.empty?
                      ""
                    else
                      <<~HTML.rstrip
          <article class="text-block">
            <h2 #{static_attrs(ja: "活動記録", en: "History", de: "Aktivitäten", zh_hant: "活動記錄")}>活動記録</h2>
#{history}
          </article>
                      HTML
                    end

  <<~HTML.rstrip
      <section class="text-band">
        <div class="wrap text-blocks">
          <article class="text-block">
            <h2 #{static_attrs(ja: "概要", en: "About", de: "Über das Spiel", zh_hant: "遊戲介紹")}>概要</h2>
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
    /      <section class="text-band">\n.*?\n      <\/section>/m,
    text_section(content),
    "#{title_id} text section"
  )
  html.gsub!(/\n?\s*<section class="link-panel">\n.*?\n\s*<\/section>/m, "")
  html = html.gsub(/alt="[^"]+ screenshot ([0-9]{2})"/, "alt=\"#{h(title)} screenshot \\1\"")

  File.write(path, html)
end

rows = CSV.read(CSV_PATH, headers: true, encoding: "bom|utf-8").map(&:to_h)
contents = rows.to_h { |row| [row.fetch("title_id"), parse_game_markdown(row.fetch("title_id"))] }
update_index(rows, contents)
rows.each { |row| update_game_page(row, contents.fetch(row.fetch("title_id"), {})) }

puts "Applied #{rows.length} games from games.csv"
