# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 8153, host: 8153
  config.vm.network "forwarded_port", guest: 10022, host: 10022

  # Install prerequisits
  config.vm.provision "shell", inline: "apt-get update"
  config.vm.provision "shell", inline: "apt-get install -y apt-transport-https ca-certificates curl software-properties-common"

  # Install Docker
  config.vm.provision "shell", inline: "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
  config.vm.provision "shell", inline: "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\""
  config.vm.provision "shell", inline: "apt-get update"
  config.vm.provision "shell", inline: "apt-get install -y docker-ce"
  config.vm.provision "shell", inline: "systemctl enable docker"
  config.vm.provision "shell", inline: "usermod -aG docker vagrant"

  # Install Docker-compose
  config.vm.provision "shell", inline: "curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose"
  config.vm.provision "shell", inline: "chmod +x /usr/local/bin/docker-compose"

  # Install build requirements
  config.vm.provision "shell", inline: "apt-get install -y make"

end
