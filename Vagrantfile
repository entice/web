# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # check https://atlas.hashicorp.com/search for other boxes
  config.vm.box = "debian/jessie64"

  # standard PostgreSQL port
  config.vm.network "forwarded_port", guest: 5432, host: 5432

  # standard PhoenixFramework dev port
  config.vm.network "forwarded_port", guest: 9000, host: 9000

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.synced_folder "./", "/vagrant/", type: "rsync", rsync__exclude: [".git/", "debs/", "_build/"]

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update

    # installing PostgreSQL & disabling user password (dont run this on prod ;P)...
    sudo apt-get install -y postgresql-9.4 postgresql-client-9.4
    sudo -u 'postgres' psql -c "ALTER ROLE postgres WITH PASSWORD ''" 1>/dev/null

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
  SHELL

  config.vm.post_up_message = "Entice test machine ready.\nTo run the server on port 9000 issue 'vagrant ssh' and run 'mix phoenix.server'.\nPostgreSQL has been automatically started (for dev and test environments) on port 5432."
end
