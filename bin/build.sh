#!/usr/bin/env bash

# check if we are in vagrant vm
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

heading() {

	echo

	echo "${cyan}==>${reset}${bold} $1${reset}"

}

success() {

	echo

	echo "${green}==>${bold} $1${reset}"

}

error() {

	echo

	echo "${red}==>${bold} Error: $1${reset}"

}

heading "Installing geth"

cd ~

[ ! -d "bin" ] && mkdir bin

[ ! -d "logs" ] && mkdir logs

# update packages

sudo apt-get update -y

sudo apt-get upgrade -y

sudo apt-get install -y software-properties-common

# add ethereum repos

sudo add-apt-repository -y ppa:ethereum/ethereum

sudo add-apt-repository -y ppa:ethereum/ethereum-dev

sudo apt-get update -y

# install geth dependencies

sudo apt-get install -y build-essential git unzip wget nodejs npm ntp cloud-utils ethereum

# add node symlink if it doesn't exist

[ ! -f "/usr/bin/node" ] && sudo ln -s /usr/bin/nodejs /usr/bin/node

cd /tmp

# install go

wget https://storage.googleapis.com/golang/go1.7.linux-amd64.tar.gz

tar -C /usr/local -xzf go1.7.linux-amd64.tar.gz


# export go bin path to vagrant/ec2 default vm user's .profile
[ $IS_VAGRANT ] && echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME_PATH/.profile

# export go bin path to current .profile
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile

source ~/.profile

# install geth
git clone https://github.com/ethereumproject/go-ethereum.git

cd go-ethereum

make all

cd build/bin

[ ! -e "$HOME_PATH/bin" ] && \

    mkdir "$HOME_PATH/bin" && \

    chown "$HOME_USER:$HOME_USER" "$HOME_PATH/bin" \

    cp abigen bootnode disasm ethtest evm geth gethrpctest rlpdump "$HOME_PATH/bin"

cp abigen bootnode disasm ethtest evm geth gethrpctest rlpdump ~/bin

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

git pull

[ ! -f "$HOME_PATH/bin/processes.json" ] && \

    [ $IS_VAGRANT ] && \

        cp -b processes-vagrant.json ../processes.json && \

        chown -R "$HOME_USER:$HOME_USER" "$HOME_PATH/bin"

[ $IS_EC2 ] && cp -b ./processes-ec2.json ../processes.json

[ ! $IS_VAGRANT ] && [ ! $IS_EC2 ] && cp -b ./processes-generic.json ../processes.json

sudo npm install

sudo npm install pm2 -g