#!/usr/bin/env bash

GO_LANG_SOURCE='https://storage.googleapis.com/golang/go1.7.linux-amd64.tar.gz'

GO_LANG_SOURCE_FILE='go1.7.linux-amd64.tar.gz'

GO_ETHEREUM_SOURCE='https://github.com/ethereumproject/go-ethereum.git'

# is_vagrant_vm file created in Vagrantfile before processing shell commands

[ -e "/etc/is_vagrant_vm" ] && \

    IS_VAGRANT=TRUE && \

    HOME_PATH=/home/vagrant && \

    HOME_USER='vagrant'

# check if we are in ec2 instance

[ `curl -s http://instance-data.ec2.internal` ] && \

    IS_EC2=TRUE && \

    HOME_PATH=/home/ubuntu && \

    HOME_USER='ubuntu'

# if not vagrant or ec2

[ ! $HOME_PATH ] && HOME_PATH=`cd && pwd`

# setup colors

red=`tput setaf 1`

green=`tput setaf 2`

cyan=`tput setaf 6`

bold=`tput bold`

reset=`tput sgr0`

# create necessary directories they don't exist

cd ~

if [ $IS_VAGRANT ]

then

    [ ! -d "$HOME_PATH/bin" ] && mkdir "$HOME_PATH/bin"

    [ ! -d "$HOME_PATH/logs" ] && mkdir "$HOME_PATH/logs"

else

    [ ! -d "bin" ] && mkdir bin

    [ ! -d "logs" ] && mkdir logs

fi

# update packages

sudo apt-get update -y

sudo apt-get upgrade -y

sudo apt-get install -y software-properties-common git vim wget nodejs npm ntp

# add ethereum repos

sudo add-apt-repository -y ppa:ethereum/ethereum

sudo add-apt-repository -y ppa:ethereum/ethereum-dev

sudo apt-get update -y

# install geth dependencies

sudo apt-get install -y build-essential ethereum

# add node symlink if it doesn't exist

[ ! -f "/usr/bin/node" ] && sudo ln -s /usr/bin/nodejs /usr/bin/node

# install grunt

sudo npm install -g grunt-cli

cd /tmp

# install go

wget "$GO_LANG_SOURCE"

sudo tar -C /usr/local -xzf "$GO_LANG_SOURCE_FILE"

# export go bin path to vagrant user's .profile

[ $IS_VAGRANT ] && echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME_PATH/.profile

# export go bin path to current .profile

echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile

source ~/.profile

# install geth

git clone "$GO_ETHEREUM_SOURCE"

cd go-ethereum

make all

cd build/bin

[ ! -e "$HOME_PATH/bin" ] && \

    mkdir "$HOME_PATH/bin" && \

    chown "$HOME_USER:$HOME_USER" "$HOME_PATH/bin" \

    chown "$HOME_USER:$HOME_USER" "$HOME_PATH/logs" \

    chown "$HOME_USER:$HOME_USER" "$HOME_PATH/tmp" \

    cp -b * "$HOME_PATH/bin"

cp -b * ~/bin

# set up time update cronjob

sudo bash -c "cat > /etc/cron.hourly/ntpdate << EOF
#!/bin/sh

pm2 flush

sudo service ntp stop

sudo ntpdate -s ntp.ubuntu.com

sudo service ntp start
EOF"

sudo chmod 755 /etc/cron.hourly/ntpdate

# add node service

if [ $IS_VAGRANT ]

then

    cd "$HOME_PATH/bin"

else

    cd ~/bin

fi

[ ! -d "www" ] && git clone https://github.com/mikeyb/etc-net-intelligence-api www

cd www

git checkout -b master origin/master

git pull

[ ! -f "$HOME_PATH/bin/processes.json" ] && \

    [ $IS_VAGRANT ] && \

        cp -b processes-vagrant.json ../processes.json && \

        chown -R "$HOME_USER:$HOME_USER" "$HOME_PATH/bin"

[ $IS_EC2 ] && cp -b ./processes-ec2.json ../processes.json

[ ! $IS_VAGRANT ] && [ ! $IS_EC2 ] && cp -b ./processes-generic.json ../processes.json

sudo npm install

sudo npm install pm2 -g
