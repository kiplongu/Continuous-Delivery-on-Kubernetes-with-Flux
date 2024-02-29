#!/bin/bash
apt-get update
apt-get install -yq git wget
# Install Docker
apt-get install -yq \
apt-transport-https \
ca-certificates \
curl \
software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key
add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
install -m 0755 -d /etc/apt/keyrings
chmod a+r /etc/apt/keyrings/docker.gpg
apt-get update
apt-get install -yq docker-ce
curl -L "https://github.com/docker/compose/releases/download/`curl
-fsSLI -o /dev/null -w %{url_effective}
https://github.com/docker/compose/releases/latest | sed 's#.*tag/##g'
&& echo`/docker-compose-$(uname -s)-$(uname -m)" -o
/usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose