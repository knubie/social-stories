Vagrant.configure("2") do |config|
	config.vm.box = "hashicorp/precise64"
	config.vm.provision "docker"
	config.vm.network :forwarded_port, host: 8080, guest: 8080
  config.vm.provision "shell",
    inline: "sudo bash -c \"curl -L https://github.com/docker/fig/releases/download/0.5.2/linux > /usr/local/bin/fig\" && chmod +x /usr/local/bin/fig"
end
