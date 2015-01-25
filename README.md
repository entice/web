[![Build Status](https://travis-ci.org/entice/web.svg)](https://travis-ci.org/entice/web)

# Entice.Web

Serves a web frontend for entice. Use this to access the worlds.

Needs:

- Erlang version: 17.1
- Elixir version: 1.0.2

To start:

1. Install dependencies with `mix deps.get`
2. Seed the database with `mix ecto.migrate Entice.Web.Repo`
3. Start server with `mix phoenix.start`
