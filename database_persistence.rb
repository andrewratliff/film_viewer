require "pg"
require "pry"

class DatabasePersistence
  attr_reader :db, :logger

  def initialize(logger = nil)
    @logger = logger
    @db = if Sinatra::Base.production?
            PG.connect(ENV["DATABASE_URL"])
          else
            PG.connect(dbname: "film_viewer")
          end
  end

  def disconnect
    @db.close
  end

  def view_all_flims
    sql = "SELECT * FROM films ORDER BY films.year;"

    result = query(sql)

    tuple_to_film_hash(result.first)
  end

  def create_new_association(name)
    sql = "INSERT INTO associations (name) VALUES ($1);"
    query(sql, name)
  end

  def find_association(name)
    sql = "SELECT id FROM associations WHERE associations.name = $1;"

    result = query(sql, name)

    tuple_to_association_hash(result.first)
  end

  def create_new_film(title, year)
    sql = "INSERT INTO films (title, year) VALUES ($1, $2) ON CONFLICT (title) DO NOTHING;"
    query(sql, title, year)
  end

  def find_film(title)
    sql = "SELECT id FROM films WHERE films.title = $1;"

    result = query(sql, title)

    tuple_to_film_hash(result.first)
  end

  def create_new_award(name, year, film_id, association_id)
    sql = "INSERT INTO awards (name, year, film_id, association_id) VALUES ($1, $2, $3, $4);"
    query(sql, name, year, film_id, association_id)
  end

  def all_films
    sql = "SELECT * FROM films";
    result = query(sql)

    result.map do |tuple|
      tuple_to_film_hash(tuple)
    end
  end

  def all_awards
    sql = <<~SQL
      SELECT *
      FROM (
        SELECT f.title, f.year, f.id, a.name FROM awards as a
        INNER JOIN films as f ON f.id = a.film_id
        WHERE a.association_id = 1
      ) AS a1
      INNER JOIN (
        SELECT a.film_id FROM awards as a
        INNER JOIN films as f ON f.id = a.film_id
        WHERE a.association_id = 2
      ) AS a2
      ON (a1.id = a2.film_id)
      INNER JOIN (
        SELECT a.film_id FROM awards as a
        INNER JOIN films as f ON f.id = a.film_id
        WHERE a.association_id = 3
      ) AS a3
      ON (a1.id = a3.film_id)
      INNER JOIN (
        SELECT a.film_id FROM awards as a
        INNER JOIN films as f ON f.id = a.film_id
        WHERE a.association_id = 4
      ) AS a4
      ON (a1.id = a4.film_id)
      ORDER BY year;
    SQL

    result = query(sql)

    result.map do |tuple|
      tuple_to_film_hash(tuple)
    end
  end

  def three_awards(association1_id, association2_id, association3_id)
    sql = <<~SQL
      SELECT *
      FROM (
        SELECT f.title, f.year, f.id, a.name FROM awards as a
        INNER JOIN films as f ON f.id = a.film_id
        WHERE a.association_id = $1
      ) AS a1
      INNER JOIN (
        SELECT a.film_id FROM awards as a
        INNER JOIN films as f ON f.id = a.film_id
        WHERE a.association_id = $2
      ) AS a2
      ON (a1.id = a2.film_id)
      INNER JOIN (
        SELECT a.film_id FROM awards as a
        INNER JOIN films as f ON f.id = a.film_id
        WHERE a.association_id = $3
      ) AS a3
      ON (a1.id = a3.film_id)
      ORDER BY year;
    SQL

    result = query(sql, association1_id, association2_id, association3_id)

    result.map do |tuple|
      tuple_to_film_hash(tuple)
    end
  end

  def two_awards(association1_id, association2_id)
    sql = <<~SQL
      SELECT *
      FROM (
        SELECT f.title, f.year, f.id, a.name FROM awards as a
        INNER JOIN films as f ON f.id = a.film_id
        WHERE a.association_id = $1
      ) AS a1
      INNER JOIN (
        SELECT a.film_id FROM awards as a
        INNER JOIN films as f ON f.id = a.film_id
        WHERE a.association_id = $2
      ) AS a2
      ON (a1.id = a2.film_id)
      ORDER BY year;
    SQL

    result = query(sql, association1_id, association2_id)

    result.map do |tuple|
      tuple_to_film_hash(tuple)
    end
  end

  def one_award(association_id)
    sql = <<~SQL
      SELECT * FROM awards as a
      INNER JOIN films as f ON f.id = a.film_id
      WHERE a.association_id = $1
      ORDER BY f.year;
    SQL

    result = query(sql, association_id)

    result.map do |tuple|
      tuple_to_film_hash(tuple)
    end
  end

  private

  def tuple_to_film_hash(tuple)
    {
      id: tuple["id"].to_i,
      title: tuple["title"],
      year: tuple["year"].to_i,
    }
  end

  def tuple_to_association_hash(tuple)
    {
      id: tuple["id"].to_i,
      name: tuple["name"],
    }
  end

  def query(statement, *params)
    if @logger
      logger.info("#{statement}: #{params}")
    else
      puts("#{statement}: #{params}")
    end

    db.exec_params(statement, params)
  end
end
