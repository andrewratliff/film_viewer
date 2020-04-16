require "pry"
require "nokogiri"
require "open-uri"
require "csv"

afi_rows = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/AFI%27s_100_Years...100_Movies")).css('table.wikitable tbody tr')

CSV.open("csv/afi.csv", "wb") do |csv|
  afi_rows.slice(1..-1).each do |row|
    title = row.css('td a')[0].text
    year = row.css('td a')[1].text
    rank97 = row.css('td')[3].text.to_i
    rank07 = row.css('td')[4].text.to_i


    csv << [title, year, rank97, rank07]
  end
end

oscars_tables = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/Academy_Award_for_Best_Picture")).css('table.wikitable')

CSV.open("csv/oscars.csv", "wb") do |csv|
  oscars_tables.each do |table|
    winners = table.css("tbody tr[style='background:#FAEB86']")

    winners.each do |winner|
      title = winner.children[1].css('a').text
      year = winner.previous_sibling.previous_sibling.children[1].children[0].css('a').text

      csv << [title, year]
    end
  end
end

golden_globes = Nokogiri::HTML(open("https://en.wikipedia.org/wiki/Golden_Globe_Award_for_Best_Motion_Picture_%E2%80%93_Drama")).css('table.wikitable')

CSV.open("csv/globes_drama.csv", "wb") do |csv|
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
    csv << [film[1], film[0], film[2], film[3]]
  end

  golden_globes.slice(1..-1).each do |table|
    rows = table.css("tbody tr td[style='background:#B0C4DE;']").map(&:parent).uniq

    rows.each do |row|
      year = row.children[1].text.to_i
      title = row.children[3].text.strip
      director = row.children[5].text.strip
      producer = row.children[7].text.strip

      csv << [title, year, director, producer]
    end
  end
end
