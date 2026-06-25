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

def replace!(html, pattern, replacement, label)
  unless html.sub!(pattern, replacement)
    warn "skip: #{label}"
  end
  html
end

def game_card(row)
  title_id = row.fetch("title_id")
  capsule = asset_file(title_id, "LibraryCapsule.png")
  tags = row.fetch("tags").split("|").map { |tag| "                    <span class=\"tag\">#{h(tag)}</span>" }.join("\n")
  release_class = row.fetch("release_label_ja").include?("発表") ? "release-label is-tba" : "release-label is-tba"

  <<~HTML.rstrip
              <a
                class="capsule-card"
                href="./games/#{h(title_id)}.html"
                style="--capsule-art: url('./assets/games/#{h(title_id)}/#{h(capsule)}')"
              >
                <div class="capsule-content">
                  <div class="tag-row" aria-label="ゲームタグ">
#{tags}
                  </div>
                  <span class="#{release_class}">#{h(row.fetch("release_label_ja"))}</span>
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
  html = html.gsub(/https:\/\/store\.steampowered\.com\/search\/\?term=[^"]+/, h(steam_url))
  html = html.gsub(/https:\/\/x\.com\/BogosorGames/, h(x_url))
  html = replace!(html, /<h1>.*?<\/h1>/, "<h1>#{h(title)}</h1>", "#{title_id} h1")
  html = replace!(
    html,
    /<p class="summary" data-ja="[^"]*" data-en="[^"]*">\n\s*.*?\n\s*<\/p>/m,
    "<p class=\"summary\" data-ja=\"#{h(row.fetch("summary_ja"))}\" data-en=\"#{h(row.fetch("summary_en"))}\">\n            #{h(row.fetch("summary_ja"))}\n          </p>",
    "#{title_id} summary"
  )
  html = replace!(html, /<span class="label" data-ja="[^"]*" data-en="[^"]*">.*?<\/span>/, "<span class=\"label\" data-ja=\"#{h(row.fetch("release_label_ja"))}\" data-en=\"#{h(row.fetch("release_label_en"))}\">#{h(row.fetch("release_label_ja"))}</span>", "#{title_id} release label")
  html = replace!(html, /<span class="label label-muted" data-ja="[^"]*" data-en="[^"]*">.*?<\/span>/, "<span class=\"label label-muted\" data-ja=\"#{h(row.fetch("status_label_ja"))}\" data-en=\"#{h(row.fetch("status_label_en"))}\">#{h(row.fetch("status_label_ja"))}</span>", "#{title_id} status label")
  html = replace!(html, /<p data-ja="[^"]*" data-en="[^"]*">[^<]*(?:概要|ルール|AI|Reversi|Skill|NyctoType|Happy Runner)[^<]*<\/p>/, "<p data-ja=\"#{h(row.fetch("overview_ja"))}\" data-en=\"#{h(row.fetch("overview_en"))}\">#{h(row.fetch("overview_ja"))}</p>", "#{title_id} overview")
  html = replace!(html, /<p data-ja="リリース時期、ストアリンク、イベント展示などの情報をここに追加できます。" data-en="[^"]*">.*?<\/p>/, "<p data-ja=\"#{h(row.fetch("updates_ja"))}\" data-en=\"#{h(row.fetch("updates_en"))}\">#{h(row.fetch("updates_ja"))}</p>", "#{title_id} updates")
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

rows = CSV.read(CSV_PATH, headers: true).map(&:to_h)
update_index(rows)
rows.each { |row| update_game_page(row) }

puts "Applied #{rows.length} games from games.csv"
