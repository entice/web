[![Build Status](https://travis-ci.org/entice/web.svg)](https://travis-ci.org/entice/web)

# Entice.Web

Serves a web frontend for entice. Use this to access the worlds.

Needs:

- Erlang version: 17.5
- Elixir version: 1.0.4

To config:

- find the config files in `./config`
- in local dev environment edit the `./config/prod.exs` config file
- in production environment (see `MIX_ENV`) use DATABASE_URL to set the PostgreSQL url:
  - get your url, check postgres info on how to do that it should look somewhat like this: `postgres://username:password@example.com/database_name`
  - replace the `postgres` with `ecto` like this: `ecto://username:password@example.com/database_name`


To start:

1. Install dependencies with `mix deps.get`
2. Create the database with `mix ecto.migrate`
3. Seed the database with `mix run priv/repo/seeds.exs`
4. Start server with `mix phoenix.server`
