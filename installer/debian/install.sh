#!/bin/bash

#Colors settings
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Author: Tasos Latsas
# Display an awesome 'spinner' while running your long shell commands
#
# Do *NOT* call _spinner function directly.
# Use {start,stop}_spinner wrapper functions

#Welcome message
clear;
echo -e "    .                              .o8                     oooo";
echo -e "  .o8                             \"888                     \`888";
echo -e ".o888oo oooo d8b oooo  oooo   .oooo888   .ooooo.   .oooo.o  888  oooo";
echo -e "  888   \`888\"\"8P \`888  \`888  d88' \`888  d88' \`88b d88(  \"8  888 .8P'";
echo -e "  888    888      888   888  888   888  888ooo888 \`\"Y88b.   888888.";
echo -e "  888 .  888      888   888  888   888  888    .o o.  )88b  888 \`88b.";
echo -e "  \"888\" d888b     \`V88V\"V8P' \`Y8bod88P\" \`Y8bod8P' 8\"\"888P' o888o o888o";
echo -e "${RED}==========================================================================${NC}";
echo -e "version 1.1.10 - Copyright (C) 2014-2021 Trudesk Inc.";
echo -e "";
echo -e "Welcome to Trudesk Install Script for Ubuntu 20.04 (fresh)!
Lets make sure we have all the required packages before moving forward..."

echo -e "Setting Clock..."

apt-get install -y ntp ntpdate;
systemctl stop ntp
ntpdate 0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org
timedatectl
systemctl start ntp

#Checking packages
echo -e "${YELLOW}Checking packages...${NC}"
echo -e "List of required packeges: git, wget, python, curl, nodejs, npm, gnupg"

read -r -p "Do you want to check packeges? [Y/n]: " response </dev/tty

case $response in
[nN]*)
  echo -e "${RED}
  Packeges check is ignored!
  Please be aware that all software packages may not be installed!
  ${NC}"
  ;;

*)
	echo -e "Performing ${GREEN}apt-get update${NC}";
	apt-get update;
	
	WGET=$(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed")
	if [ $WGET -eq 0 ]; then
		echo -e "${YELLOW}Installing wget${NC}"
		apt-get install wget --yes;
	elif [ $WGET -eq 1 ]; then
		echo -e "${GREEN}wget is installed!${NC}"
	fi
	
	PYTHON=$(dpkg-query -W -f='${Status}' python 2>/dev/null | grep -c "ok installed")
	if [ $PYTHON -eq 0 ]; then
		echo -e "${YELLOW}Installing python${NC}"
		apt-get install python --yes;
	elif [ $PYTHON -eq 1 ]; then
		echo -e "${GREEN}python is installed!${NC}"
	fi

	CURL=$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed")
	if [ $CURL -eq 0 ]; then
		echo -e "${YELLOW}Installing curl${NC}"
		apt-get install curl --yes;
	elif [ $CURL -eq 1 ]; then
		echo -e "${GREEN}curl is installed!${NC}"
	fi

	GNUPG=$(dpkg-query -W -f='${Status}' gnupg 2>/dev/null | grep -c "ok installed")
	if [ $GNUPG -eq 0 ]; then
		echo -e "${YELLOW}Installing gnupg${NC}"
		apt-get install gnupg --yes;
	elif [ $GNUPG -eq 1 ]; then
		echo -e "${GREEN}gnupg is installed!${NC}"
	fi

	GIT=$(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed")
	if [ $GIT -eq 0 ]; then
		echo -e "${YELLOW}Installing git${NC}"
		apt-get install git --yes;
	elif [ $GIT -eq 1 ]; then
		echo -e "${GREEN}git is installed!${NC}"
	fi
	
	NPM=$(dpkg-query -W -f='${Status}' npm 2>/dev/null | grep -c "ok installed")
	if [ $NPM -eq 0 ]; then
		echo -e "${YELLOW}Installing npm${NC}"
		apt-get install npm --yes;
	elif [ $NPM -eq 1 ]; then
		echo -e "${GREEN}npm is installed!${NC}"
	fi
	
	NODE=$(nvm current 2>/dev/null | grep -c "v12")
	if [ $NPM -eq 0 ]; then
		curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh -o install_nvm.sh
		bash install_nvm.sh
		source ~/.profile
		nvm install v12.22.7 
	elif [ $NPM -eq 1 ]; then
		echo -e "${GREEN}node is installed!${NC}"
	fi
	;;
esac

echo -e ""

read -r -p "Do you want to install Elasticsearch? [y/N]: " response </dev/tty

case $response in
[yY]*)
	echo -e "${YELLOW}Installing Elasticsearch${NC}"
	wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add
	echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
	apt-get install -y default-jdk;
	apt-get install -y apt-transport-https elasticsearch kibana;
	echo "network.host: [_local_]" >> /etc/elasticsearch/elasticsearch.yml
	systemctl enable elasticsearch
	systemctl start elasticsearch
	;;
esac

read -r -p "Do you want to install MongoDB? [y/N]: " response </dev/tty
case $response in
[yY]*)
	echo -e "${YELLOW}Installing MongoDB 4.0${NC}"
	wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
	echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/5.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
	apt-get update
	apt-get install -y mongodb-org mongodb-org-shell
	systemctl daemon-reload
	systemctl enable mongod
	service mongod start

	echo -e "";
	echo -e "Waiting for MongoDB to start...";
	sleep 10

	cat >/etc/mongosetup.js <<EOL
db.system.users.remove({});
db.system.version.remove({});
db.system.version.insert({"_id": "authSchema", "currentVersion": 3});
EOL
	mongo /etc/mongosetup.js
	service mongod restart 

	echo "Restarting MongoDB..."
	sleep 5

	cat > /etc/mongosetup_trudesk.js <<EOL
db = db.getSiblingDB('trudesk');
db.createUser({"user": "trudesk", "pwd": "#TruDesk1$", "roles": ["readWrite", "dbAdmin"]});
EOL
	mongo /etc/mongosetup_trudesk.js
  ;;
  
*)
	echo -e "${RED}MongoDB install skipped...${NC}"
	echo -e "${YELLOW}Installing MongoDB Tools...${NC}"
	wget https://repo.mongodb.org/apt/ubuntu/dists/focal/mongodb-org/4.4/multiverse/binary-amd64/mongodb-org-tools_4.4.8_amd64.deb;
	dpkg -i mongodb-org-tools_4.4.8_amd64.deb;
	rm -rf mongodb-org-tools_4.4.8_amd64.deb
	;;
esac

mkdir /etc/trudesk 2>/dev/null
cp -fR ../../../trudesk /etc/trudesk
touch /etc/trudesk/logs/output.log
echo -e "${BLUE}Building...${NC} (its going to take a few minutes)"
npm install -g yarn pm2 grunt-cli;
# Lets checkout the version tag
git checkout v1.1.10;
yarn install;
sleep 3
# This last line must be all in one command due to the exit nature of the build command.
echo -e "${BLUE}Starting...${NC}" && yarn build && NODE_ENV=production pm2 start /etc/trudesk/app.js --name trudesk -l /etc/trudesk/logs/output.log --merge-logs && pm2 save && pm2 startup && echo -e "${GREEN}Installation Complete.${NC}"
