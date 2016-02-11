#!/bin/sh

sudo apt-get update
sudo apt-get upgrade


# installing PostgreSQL & disabling user password (dont run this on prod ;P)...
sudo apt-get install -y postgresql-9.4 postgresql-client-9.4
sudo -u 'postgres' psql -c "ALTER ROLE postgres WITH PASSWORD ''" 1>/dev/null

# init the postgres service
cd /etc/postgresql/9.4/main
sudo rm -f pg_hba.conf

cat | sudo -u postgres tee pg_hba.conf <<- EOM
local all all trust
host all all 127.0.0.1/32 trust
host all all ::1/128 trust
EOM

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "postgresql.conf"
sudo service postgresql restart
cd -


# installing Git...
sudo apt-get install -y git


# installing Elixir...
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb && rm erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install -y esl-erlang elixir rebar


# installing entice & seeding the db...
cd /vagrant/
mix local.hex --force
mix deps.get
sudo -u 'postgres' psql -c "CREATE DATABASE entice;"
sudo -u 'postgres' psql -c "CREATE DATABASE entice_test;"
MIX_ENV=dev mix ecto.migrate
MIX_ENV=dev mix run priv/repo/seeds.exs
MIX_ENV=test mix ecto.migrate
MIX_ENV=test mix run priv/repo/seeds.exs
