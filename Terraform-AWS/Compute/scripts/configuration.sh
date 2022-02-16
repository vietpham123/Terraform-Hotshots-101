#!/bin/bash
echo "----- Cloning down gemfiles and raddit application -----"
sudo git clone https://github.com/Artemmkin/raddit.git /var/lib/raddit

echo "----- Installing Ruby -----"
sudo apt-get update && sudo apt-get install -y ruby-full build-essential

echo "----- Installing Bundler -----"
sudo gem install bundler -v "$(grep -A 1 "BUNDLED WITH" ~/var/lib/raddit/Gemfile.lock | tail -n 1)"

echo "----- Building Gemfile -----"
cd /var/lib/raddit && sudo bundle install && cd

echo "----- Installing and configuring Mongodb -----"
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update && sudo apt-get install -y mongodb-org

echo "----- Starting Mongodb -----"
sudo systemctl start mongod
sudo systemctl enable mongod

echo "----- Downloading service file to system -----"
sudo wget https://raw.githubusercontent.com/vietpham123/Automation-HotShots/main/raddit.service -P /etc/systemd/system/

echo "----- Starting Raddit service -----"
sudo systemctl start raddit
sudo systemctl enable raddit
