require "pry"
require "httparty"
require "uri"
require "dotenv/load"

class OMDB
  OMDB_URL = "http://www.omdbapi.com/?apikey=#{ENV[OMDB_API_KEY]}&type=movie".freeze


  def self.get_json(title, year = nil)
    url = URI::encode(OMDB_URL + "&s=#{title}&y=#{year}")

    response = HTTParty.get(url)

    JSON.parse(response.body)
  end
end

binding.pry

puts 'end'
