# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.network "private_network", ip: "192.168.33.44"

  config.vm.synced_folder "/path/to/etc-net-intelligence-api", "/home/vagrant/bin/www"

  config.vm.synced_folder "/path/to/etcstat.us", "/home/vagrant/etcstat.us"

  config.vm.provider "virtualbox" do |vb|

    vb.memory = "1024"

  end

  config.vm.provision "shell", inline: <<-SHELL

    touch /etc/is_vagrant_vm

    /home/vagrant/bin/www/bin/build.sh

  SHELL

end