require 'json'
require "nokogiri"
require "open-uri"
require "csv"
require "pry"

AFI_98 = 1
AFI_07 = 2
ACADEMY_AWARD = 3
GOLDEN_GLOBE = 4

# {
#   "films": [
#     {
#       "title": "The Godfather",
#       "year": "1972",
#       "accolades": ["AFI 1998", "AFI 2007", "Academy Award", "Golden Globes"]
#     },
#     {
#       "title": "Citizen Kane",
#       "year": "1941",
#       "accolades": ["AFI 1998", "AFI 2007"]
#     }
#   ]
# }

FILMS = []

def addToFilms(film)
  titles = FILMS.map { |film| film[:title] }
  title = film[:title]

  if (titles.include?(title))
    found = FILMS.find { |film| film[:title] == title }
    found[:accolades] = found[:accolades].concat(film[:accolades]).uniq
  else
    FILMS.push(film)
  end
end

afi_rows = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/AFI%27s_100_Years...100_Movies")).css('table.wikitable tbody tr')

afi_rows.slice(1..-1).each do |row|
    title = row.css('td a')[0].text
    year = row.css('td a')[1].text
    accolades = []

    if (row.css('td')[3].text.to_i > 0)
      accolades << AFI_98
    end

    if (row.css('td')[4].text.to_i > 0)
      accolades << AFI_07
    end

  addToFilms({
    title: title,
    year: year,
    accolades: accolades,
  })
end

oscars_tables = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/Academy_Award_for_Best_Picture")).css('table.wikitable')

oscars_tables.each do |table|
  winners = table.css("tbody tr[style='background:#FAEB86']")

  winners.each do |winner|
    title = winner.children[1].css('a').text
    year = winner.previous_sibling.previous_sibling.children[1].children[0].css('a').text
    accolades = [3]

    addToFilms({
      title: title,
      year: year,
      accolades: accolades,
    })
  end
end

golden_globes = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/Golden_Globe_Award_for_Best_Motion_Picture_%E2%80%93_Drama")).css('table.wikitable')

[
  [1943, "The Song of Bernadette", "Henry King", "William Perlberg"],
  [1944, "Going My Way", "Leo McCarey", "Leo McCarey"],
  [1945, "The Lost Weekend", "Billy Wilder", "Charles Brackett"],
  [1946, "The Best Years of Our Lives", "William Wyler", "Samuel Goldwyn"],
  [1947, "Gentleman's Agreement", "Elia Kazan", "Darryl F. Zanuck"],
  [1948, "Johnny Belinda", "Jean Negulesco", "Jerry Wald"],
  [1948, "The Treasure of the Sierra Madre", "John Huston", "Henry Blanke"],
  [1949, "All the King's Men", "Robert Rossen", "Robert Rossen"],
].each do |film|
  title, year, _, _ = [film[1], film[0], film[2], film[3]]

  addToFilms({
    title: title,
    year: year,
    accolades: [4],
  })
end

golden_globes.slice(1..-1).each do |table|
  rows = table.css("tbody tr td[style='background:#B0C4DE;']").map(&:parent).uniq

  rows.each do |row|
    year = row.children[1].text.to_i
    title = row.children[3].text.strip
    # director = row.children[5].text.strip
    # producer = row.children[7].text.strip

    addToFilms({
      title: title,
      year: year,
      accolades: [4],
    })
  end
end

File.open("json/films.json", "w") do |f|
  f.write(FILMS.to_json)
end
