CREATE TABLE films (
  id serial PRIMARY KEY,
  title text NOT NULL UNIQUE,
  year integer NOT NULL
);

CREATE TABLE associations (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE awards(
  id serial PRIMARY KEY,
  name text NOT NULL,
  year integer NOT NULL,
  film_id integer NOT NULL REFERENCES films(id),
  association_id integer NOT NULL REFERENCES associations(id)
);
