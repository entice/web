[![Build Status](https://travis-ci.org/entice/web.svg)](https://travis-ci.org/entice/web)

# Entice.Web

Serves a web frontend for entice. Use this to access the worlds.

Needs:

- Erlang version: 17.1
- Elixir version: 1.0.2

To config:

- find the config files in `./config`
- in local dev environment edit the `./config/prod.exs` config file
- in production environment (see `MIX_ENV`) use DATABASE_URL to set the PostgreSQL url:
  - get your url, check postgres info on how to do that it should look somewhat like this: `postgres://username:password@example.com/database_name`
  - replace the `postgres` with `ecto` like this: `ecto://username:password@example.com/database_name`


To start:

1. Install dependencies with `mix deps.get`
2. Seed the database with `mix ecto.migrate Entice.Web.Repo`
3. Start server with `mix phoenix.server`
