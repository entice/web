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

  config.vm.provision "shell", path: "bootstrap.sh", privileged: false

  config.vm.post_up_message = "Entice test machine ready.\nTo run the server on port 9000 issue 'vagrant ssh' and run 'mix phoenix.server'.\nPostgreSQL has been automatically started (for dev and test environments) on port 5432."
end
