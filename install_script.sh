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

function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne ${2}
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}

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
# NTP=$(dpkg-query -W -f='${Status}' ntp 2>/dev/null | grep -c "ok installed")
#   if [ $(dpkg-query -W -f='${Status}' ntp 2>/dev/null | grep -c "ok installed") -eq 0 ];
#   then
#     echo -e "${YELLOW}Installing ntp${NC}"
#     apt-get install -y ntp ntpdate > /dev/null;
#     elif [ $(dpkg-query -W -f='${Status}' ntp 2>/dev/null | grep -c "ok installed") -eq 1 ];
#     then
#       echo -e "${GREEN}ntp is installed!${NC}"
#   fi
apt-get install -y ntp ntpdate > /dev/null;
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
start_spinner "Performing ${GREEN}apt-get update${NC}";
apt-get update > /dev/null;
stop_spinner $?;
WGET=$(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing wget${NC}"
    apt-get install wget --yes > /dev/null;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}wget is installed!${NC}"
  fi
PYTHON=$(dpkg-query -W -f='${Status}' python 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' python 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing python${NC}"
    apt-get install python --yes > /dev/null;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' python 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}python is installed!${NC}"
  fi
CURL=$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing curl${NC}"
    apt-get install curl --yes > /dev/null;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}curl is installed!${NC}"
  fi
GNUPG=$(dpkg-query -W -f='${Status}' gnupg 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' gnupg 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing gnupg${NC}"
    apt-get install curl --yes > /dev/null;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' gnupg 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}gnupg is installed!${NC}"
  fi
GIT=$(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing git${NC}"
    apt-get install git --yes > /dev/null;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}git is installed!${NC}"
  fi
NODEJS=$(dpkg-query -W -f='${Status}' nodejs 2>/dev/null | grep -c "ok installed")
  if [ $(dpkg-query -W -f='${Status}' nodejs 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    start_spinner "${YELLOW}Installing nodejs${NC}"
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash > /dev/null 2>&1
    apt-get install -y nodejs > /dev/null 2>&1;
    apt-get install -y build-essential > /dev/null 2>&1;
    stop_spinner $?
    elif [ $(dpkg-query -W -f='${Status}' nodejs 2>/dev/null | grep -c "ok installed") -eq 1 ];
    then
      echo -e "${GREEN}nodejs is installed!${NC}"
  fi
# NODE=$(dpkg-query -W -f='${Status}' nodejs-legacy 2>/dev/null | grep -c "ok installed")
#   if [ $(dpkg-query -W -f='${Status}' nodejs-legacy 2>/dev/null | grep -c "ok installed") -eq 0 ];
#   then
#     echo -e "${YELLOW}Installing nodejs-legacy${NC}"
#     apt-get install nodejs-legacy --yes;
#     elif [ $(dpkg-query -W -f='${Status}' nodejs-legacy 2>/dev/null | grep -c "ok installed") -eq 1 ];
#     then
#       echo -e "${GREEN}nodejs-legacy is installed!${NC}"
#   fi

  ;;
esac

echo -e ""

read -r -p "Do you want to install Elasticsearch? [y/N]: " response </dev/tty

case $response in
[yY]*)
  start_spinner "${YELLOW}Installing Elasticsearch${NC}"
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add > /dev/null 2>&1
  echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list > /dev/null 2>&1
  apt-get update > /dev/null;
  apt-get install -y openjdk-8-jre > /dev/null 2>&1;
  apt-get install -y apt-transport-https elasticsearch kibana > /dev/null 2>&1;
  echo "network.host: [_local_]" >> /etc/elasticsearch/elasticsearch.yml
  systemctl enable elasticsearch
  systemctl start elasticsearch
  stop_spinner $?
  ;;
esac

read -r -p "Do you want to install MongoDB? [y/N]: " response </dev/tty
case $response in
[yY]*)
  start_spinner "${YELLOW}Installing MongoDB 4.0${NC}"
  apt-get install gnupg > /dev/null
  wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add - > /dev/null 2>&1
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null 2>&1
  apt-get update > /dev/null;
  apt-get install -y mongodb-org mongodb-org-shell > /dev/null;
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
  mongo /etc/mongosetup.js > /dev/null 2>&1
  service mongod restart > /dev/null 2>&1

echo "Restarting MongoDB..."
sleep 5

cat > /etc/mongosetup_trudesk.js <<EOL
db = db.getSiblingDB('trudesk');
db.createUser({"user": "trudesk", "pwd": "#TruDesk1$", "roles": ["readWrite", "dbAdmin"]});
EOL
  mongo /etc/mongosetup_trudesk.js > /dev/null 2>&1
  stop_spinner $?
  ;;
*)
  echo -e "${RED}MongoDB install skipped...${NC}"
  start_spinner "${YELLOW}Installing MongoDB Tools...${NC}"
  wget https://repo.mongodb.org/apt/ubuntu/dists/focal/mongodb-org/4.4/multiverse/binary-amd64/mongodb-org-tools_4.4.8_amd64.deb > /dev/null 2>&1;
  dpkg -i mongodb-org-tools_4.4.8_amd64.deb > /dev/null;
  rm -rf mongodb-org-tools_4.4.8_amd64.deb
  stop_spinner $?
  ;;
esac

start_spinner "${YELLOW}Downloading the latest version of ${NC}Trudesk${RED}.${NC}"
cd /etc/
git clone http://www.github.com/polonel/trudesk > /dev/null 2>&1;
cd /etc/trudesk
touch /etc/trudesk/logs/output.log
stop_spinner $?
start_spinner "${BLUE}Building...${NC} (its going to take a few minutes)"
npm install -g yarn pm2 grunt-cli > /dev/null 2>&1;
# Lets checkout the version tag
git checkout v1.1.10 > /dev/null 2>&1;
yarn install > /dev/null 2>&1;
sleep 3
stop_spinner $?
# This last line must be all in one command due to the exit nature of the build command.
start_spinner "${BLUE}Starting...${NC}" && yarn build > /dev/null && NODE_ENV=production pm2 start /etc/trudesk/app.js --name trudesk -l /etc/trudesk/logs/output.log --merge-logs > /dev/null && pm2 save > /dev/null && pm2 startup > /dev/null 2>&1 && stop_spinner $? && echo -e "${GREEN}Installation Complete.${NC}"
