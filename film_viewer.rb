require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "pry"

require_relative "database_persistence"

configure do
  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb" if development?
end

before do
  @storage = DatabasePersistence.new(logger)
end

after do
  @storage.disconnect
end

get "/" do
  @films = @storage.all_films.sort_by { |film| film[:year] }

  erb :results
end

get "/search" do
  @ids = params.keys.map(&:to_i)

  if @ids.empty?
    redirect "/"
  end

  @films = if (@ids.count == 4)
             @storage.all_awards
           elsif (@ids.count == 3)
             @storage.three_awards(@ids[0], @ids[1], @ids[2])
           elsif (@ids.count == 2)
             @storage.two_awards(@ids[0], @ids[1])
           elsif (@ids.count == 1)
             @storage.one_award(@ids[0])
           end

  @total = @films.count

  erb :results
end
