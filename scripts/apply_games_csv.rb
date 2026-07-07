#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "erb"

ROOT = File.expand_path("..", __dir__)
CSV_PATH = File.join(ROOT, "games.csv")
INDEX_PATH = File.join(ROOT, "docs", "index.html")

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

def release_label_class(label)
  return "release-label is-released" if label.include?("発売中")
  return "release-label is-event" if label.match?(/出展|展示|gamescom|TGS/i)

  "release-label is-tba"
end

def game_page_release_label_class(label)
  return "label label-event" if label.match?(/出展|展示|gamescom|TGS/i)

  "label"
end

def release_labels(row)
  ja_labels = row.fetch("release_label_ja").split("|").map(&:strip)
  en_labels = row.fetch("release_label_en").split("|").map(&:strip)

  labels = ja_labels.each_with_index.map do |ja_label, index|
    en_label = en_labels[index] || en_labels.first || ja_label
    "                    <span class=\"#{release_label_class(ja_label)}\" data-ja=\"#{h(ja_label)}\" data-en=\"#{h(en_label)}\">#{h(ja_label)}</span>"
  end.join("\n")

  <<~HTML.rstrip
                  <div class="release-labels" aria-label="公開・展示ステータス">
#{labels}
                  </div>
  HTML
end

def game_page_release_labels(row)
  ja_labels = row.fetch("release_label_ja").split("|").map(&:strip)
  en_labels = row.fetch("release_label_en").split("|").map(&:strip)

  ja_labels.each_with_index.map do |ja_label, index|
    en_label = en_labels[index] || en_labels.first || ja_label
    "            <span class=\"#{game_page_release_label_class(ja_label)}\" data-ja=\"#{h(ja_label)}\" data-en=\"#{h(en_label)}\">#{h(ja_label)}</span>"
  end.join("\n")
end

def split_items(value)
  value.to_s.split(/\s*\|\s*|\r?\n/).map(&:strip).reject(&:empty?)
end

def info_list(row, ja_key, en_key)
  ja_items = split_items(row_value(row, ja_key))
  en_items = split_items(row_value(row, en_key))

  return "" if ja_items.empty?

  items = ja_items.each_with_index.map do |ja_item, index|
    en_item = en_items[index] || en_items.first || ja_item
    "              <li data-ja=\"#{h(ja_item)}\" data-en=\"#{h(en_item)}\">#{h(ja_item)}</li>"
  end.join("\n")

  <<~HTML.rstrip
            <ul class="info-list">
#{items}
            </ul>
  HTML
end

def text_section(row)
  overview_ja = row.fetch("overview_ja")
  overview_en = row.fetch("overview_en")

  <<~HTML.rstrip
      <section class="text-band">
        <div class="wrap text-blocks">
          <article class="text-block">
            <h2 data-ja="概要" data-en="About">概要</h2>
            <p data-ja="#{h(overview_ja)}" data-en="#{h(overview_en)}">#{h(overview_ja)}</p>
          </article>
          <article class="text-block">
            <h2 data-ja="今後の予定" data-en="Plans">今後の予定</h2>
#{info_list(row, "plan_items_ja", "plan_items_en")}
          </article>
          <article class="text-block">
            <h2 data-ja="これまでの動き" data-en="History">これまでの動き</h2>
#{info_list(row, "history_items_ja", "history_items_en")}
          </article>
        </div>
      </section>
  HTML
end

def game_card(row)
  title_id = row.fetch("title_id")
  capsule = asset_file(title_id, "LibraryCapsule.png")
  platforms = platform_icons(row)
  labels = release_labels(row)

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
                  <p data-ja="#{h(row.fetch("card_text_ja"))}" data-en="#{h(row.fetch("card_text_en"))}">#{h(row.fetch("card_text_ja"))}</p>
                </div>
              </a>
  HTML
end

def update_index(rows)
  html = File.read(INDEX_PATH)
  cards = rows.map { |row| game_card(row) }.join("\n\n")
  html = replace!(
    html,
    /            <div class="capsule-shelf" aria-label="Steamライブラリーカプセル">\n.*?\n            <\/div>/m,
    "            <div class=\"capsule-shelf\" aria-label=\"Steamライブラリーカプセル\">\n#{cards}\n            </div>",
    "index capsule shelf"
  )
  File.write(INDEX_PATH, html)
end

def update_game_page(row)
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
  html = replace!(
    html,
    /<p class="summary" data-ja="[^"]*" data-en="[^"]*">\n\s*.*?\n\s*<\/p>/m,
    "<p class=\"summary\" data-ja=\"#{h(row.fetch("summary_ja"))}\" data-en=\"#{h(row.fetch("summary_en"))}\">\n            #{h(row.fetch("summary_ja"))}\n          </p>",
    "#{title_id} summary"
  )
  html = replace!(
    html,
    /          <div class="status-row">\n\s*<span class="label[^"]*" data-ja="[^"]*" data-en="[^"]*">.*?<\/span>\n(?:\s*<span class="label[^"]*" data-ja="[^"]*" data-en="[^"]*">.*?<\/span>\n)*\s*<span class="label label-muted" data-ja="[^"]*" data-en="[^"]*">.*?<\/span>\n\s*<\/div>/m,
    "          <div class=\"status-row\">\n#{game_page_release_labels(row)}\n            <span class=\"label label-muted\" data-ja=\"#{h(row.fetch("status_label_ja"))}\" data-en=\"#{h(row.fetch("status_label_en"))}\">#{h(row.fetch("status_label_ja"))}</span>\n          </div>",
    "#{title_id} status row"
  )
  html = replace!(
    html,
    /      <section class="text-band">\n.*?\n      <\/section>/m,
    text_section(row),
    "#{title_id} text section"
  )
  html = replace!(html, /<p data-ja="ストアページ、更新情報、問い合わせ先などを必要に応じて追加できます。" data-en="[^"]*">.*?<\/p>/, "<p data-ja=\"#{h(row.fetch("links_text_ja"))}\" data-en=\"#{h(row.fetch("links_text_en"))}\">#{h(row.fetch("links_text_ja"))}</p>", "#{title_id} links text")
  html = replace!(
    html,
    /<div class="meta-row" aria-label="基本情報">\n\s*<span><b>Platform<\/b>.*?<\/span>\n\s*<span><b>Status<\/b>.*?<\/span>\n\s*<span><b>Links<\/b>.*?<\/span>\n\s*<\/div>/m,
    "<div class=\"meta-row\" aria-label=\"基本情報\">\n                <span><b>Platform</b> #{h(row.fetch("meta_platform"))}</span>\n                <span><b>Status</b> #{h(row.fetch("meta_status_ja"))}</span>\n                <span><b>Links</b> #{h(row.fetch("meta_links"))}</span>\n              </div>",
    "#{title_id} meta row"
  )
  html = html.gsub(/alt="[^"]+ screenshot ([0-9]{2})"/, "alt=\"#{h(title)} screenshot \\1\"")

  File.write(path, html)
end

rows = CSV.read(CSV_PATH, headers: true, encoding: "bom|utf-8").map(&:to_h)
update_index(rows)
rows.each { |row| update_game_page(row) }

puts "Applied #{rows.length} games from games.csv"
