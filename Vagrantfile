# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  config.vm.define "cord" do |cord|
    cord.vm.box = "apache"

    # The most common configuration options are documented and commented below.
    # For a complete reference, please see the online documentation at
    # https://docs.vagrantup.com.
    cord.vm.hostname = "bp-cord"
  
    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://atlas.hashicorp.com/search.
    cord.vm.box = "ubuntu/xenial64"
  
    # Disable automatic box update checking. If you disable this, then
    # boxes will only be checked for updates when the user runs
    # `vagrant box outdated`. This is not recommended.
    # cord.vm.box_check_update = true
  
    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    # cord.vm.network "forwarded_port", guest: 80, host: 8080
  
    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    # cord.vm.network "private_network", ip: "192.168.33.10"
  
    # Create a public network, which generally matched to bridged network.
    # Bridged networks make the machine appear as another physical device on
    # your network.
    # cord.vm.network "public_network"
  
    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder. The second argument is
    # the path on the guest to mount the folder. And the optional third
    # argument is a set of non-required options.
    # cord.vm.synced_folder "../data", "/vagrant_data"
  
    # Provider-specific configuration so you can fine-tune various
    # backing providers for Vagrant. These expose provider-specific options.
    # Example for VirtualBox:
    #
    cord.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
   
      # Customize the amount of memory on the VM:
      vb.memory = "2048"
      vb.cpus = 2
    end
  
    #
    # View the documentation for the provider you are using for more
    # information on available options.
  
    # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
    # such as FTP and Heroku are also available. See the documentation at
    # https://docs.vagrantup.com/v2/push/atlas.html for more information.
    # cord.push.define "atlas" do |push|
    #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
    # end
  
    # Enable provisioning with a shell script. Additional provisioners such as
    # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
    # documentation for more information about their specific syntax and use.
    cord.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y docker.io openvswitch-switch make python-scapy
      sudo usermod -aG docker ubuntu
      curl -sSL "https://github.com/docker/compose/releases/download/1.11.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod 755 /usr/local/bin/docker-compose
      curl -sSL "https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker" -o /usr/local/bin/ovs-docker
      chmod 755 /usr/local/bin/ovs-docker
    SHELL
  end
end
