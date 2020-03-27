# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  # deploy Salt VM
  config.vm.define "salt" do |salt|
    salt.vm.hostname = "salt.sva.de"
    # use OpenSUSE 15.x box
    salt.vm.box = "generic/opensuse15"
    # rsync
    config.vm.synced_folder ".", "/vagrant", type: "rsync"
    # define additional private client network
    salt.vm.network "private_network", ip: "192.168.25.100"
     salt.vm.provider "virtualbox" do |vb|
       # customize the amount of memory on the VM:
       vb.memory = "1024"
     end
    # install Ansible
    salt.vm.provision "shell", inline: <<-SHELL
     zypper --non-interactive install rpm-python ansible python-xml vim
    SHELL
    # install Salt
    salt.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/salt.yml"
    end
  end

  # deploy Client VM
  config.vm.define "client" do |client|
    client.vm.hostname = "client.sva.de"
    # use OpenSUSE 15.x box
    client.vm.box = "generic/opensuse15"
    # rsync
    config.vm.synced_folder ".", "/vagrant", type: "rsync"
    # forward webserver port
    client.vm.network "forwarded_port", guest: 80, host: 8888
    # define additional private client network
    client.vm.network "private_network", ip: "192.168.25.101"
    client.vm.provider "virtualbox" do |vb|
       # customize the amount of memory on the VM:
       vb.memory = "1024"
     end
    # install Ansible
    client.vm.provision "shell", inline: <<-SHELL
     zypper --non-interactive install rpm-python ansible python-xml vim
    SHELL
    # install Salt
    client.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/minion.yml"
    end
  end

end
