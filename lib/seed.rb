require "pg"
require "csv"
require "pry"

require_relative "../database_persistence"

class Seed
  def run!
    seed_afi!
    seed_oscars!
    seed_golden_globes!("Golden Globes", "Drama", "globes_drama")
  end

  private

  def seed_afi!
    afi_98_name = "American Film Institute (1998)".freeze
    afi_07_name = "American Film Institute (2007)".freeze
    db = DatabasePersistence.new
    db.create_new_association(afi_98_name)
    db.create_new_association(afi_07_name)
    afi_98_id = db.find_association(afi_98_name)[:id]
    afi_07_id = db.find_association(afi_07_name)[:id]
    db.disconnect

    CSV.read("csv/afi.csv").each do |row|
      db = DatabasePersistence.new

      title = row[0]
      year = row[1].to_i
      rank_98 = row[2].to_i
      rank_07 = row[3].to_i

      db.create_new_film(title, year)

      film_id = db.find_film(title)[:id]

      if (rank_98 != 0)
        db.create_new_award(rank_98, 1998, film_id, afi_98_id)
      end

      if (rank_07 != 0)
        db.create_new_award(rank_07, 2007, film_id, afi_07_id)
      end

      db.disconnect
    end
  end

  def seed_oscars!
    oscars_name = "Academy Awards".freeze
    db = DatabasePersistence.new
    db.create_new_association(oscars_name)
    oscars_id = db.find_association(oscars_name)[:id]
    db.disconnect

    CSV.read("csv/oscars.csv").each do |row|
      db = DatabasePersistence.new

      title = row[0]
      year = row[1].to_i
      name = "Best Picture"

      db.create_new_film(title, year)

      film_id = db.find_film(title)[:id]

      db.create_new_award(name, year + 1, film_id, oscars_id)

      db.disconnect
    end
  end

  def seed_golden_globes!(association_name, award_name, csv_name)
    db = DatabasePersistence.new
    db.create_new_association(association_name)
    association_id = db.find_association(association_name)[:id]
    db.disconnect

    CSV.read("csv/#{csv_name}.csv").each do |row|
      db = DatabasePersistence.new

      title = row[0]
      year = row[1].to_i

      db.create_new_film(title, year)

      film_id = db.find_film(title)[:id]

      # TODO: check for year vs year + 1
      db.create_new_award(award_name, year, film_id, association_id)

      db.disconnect
    end
  end

  def parse_year(year)
    year.length == 4 ? year : year.split('/').first
  end
end

Seed.new.run!
