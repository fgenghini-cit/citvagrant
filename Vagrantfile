# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.hostname = "vagrant.cfn"
  config.vm.box = "ubuntu/precise64"
  config.vm.provision :shell, :path => "./vagrant/install.sh"

  config.vm.network "private_network", ip: "10.0.1.10"
  config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.network "forwarded_port", guest: 3306, host: 8001

  config.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
  end
end
