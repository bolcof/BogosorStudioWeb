#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "erb"

ROOT = File.expand_path("..", __dir__)
CSV_PATH = File.join(ROOT, "games.csv")
CONTENT_DIR = File.join(ROOT, "content", "games")
INDEX_PATH = File.join(ROOT, "docs", "index.html")
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

  LANGUAGES.each do |language|
    path = File.join(CONTENT_DIR, "#{title_id}.#{language.fetch(:code)}.md")
    content[language.fetch(:code)] = parse_markdown_sections(path) if File.exist?(path)
  end

  if content.empty?
    legacy_path = File.join(CONTENT_DIR, "#{title_id}.md")
    return warn("skip: missing content #{legacy_path}") && {} unless File.exist?(legacy_path)

    content = parse_legacy_game_markdown(legacy_path)
  end

  ja_content = content["ja"] || content.values.first || {}
  LANGUAGES.each { |language| content[language.fetch(:code)] ||= ja_content }
  content
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
    "            <span class=\"#{label_class(label[:kind], :page)}\" #{localized_attrs(label[:text])}>#{h(label[:text].fetch("ja"))}</span>"
  end.join("\n")

  "          <div class=\"status-row\">\n#{html}\n          </div>"
end

def info_list(content, section)
  items_by_language = LANGUAGES.to_h do |language|
    code = language.fetch(:code)
    [code, markdown_list_items(content_text(content, code, section))]
  end
  ja_items = items_by_language["ja"]

  return "" if ja_items.empty?

  items = ja_items.each_with_index.map do |ja_item, index|
    values = LANGUAGES.to_h do |language|
      code = language.fetch(:code)
      language_items = items_by_language[code]
      item = language_items[index] || language_items.first || ja_item
      [code, inline_markdown_to_html(item)]
    end
    "              <li #{localized_attrs(values, html: true)}>#{values.fetch("ja")}</li>"
  end.join("\n")

  <<~HTML.rstrip
            <ul class="info-list">
#{items}
            </ul>
  HTML
end

def text_section(content)
  plans = info_list(content, "plans")
  history = info_list(content, "history")
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

def update_index(rows, contents)
  html = File.read(INDEX_PATH)
  cards = rows.map { |row| game_card(row, contents.fetch(row.fetch("title_id"), {})) }.join("\n\n")
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
  html = replace!(html, /<h1>.*?<\/h1>/, "<h1>#{h(title)}</h1>", "#{title_id} h1")
  summary_texts = localized_texts(content, "summary", title, compact: true)
  html = replace!(
    html,
    /<p class="summary"[^>]*>\n\s*.*?\n\s*<\/p>/m,
    "<p class=\"summary\" #{localized_attrs(summary_texts)}>\n            #{h(summary_texts.fetch("ja"))}\n          </p>",
    "#{title_id} summary"
  )
  html = replace!(
    html,
    /          <div class="status-row">\n.*?\n          <\/div>/m,
    game_page_status_row(content),
    "#{title_id} status row"
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
