#!/usr/bin/env bash

# setup colors

red=`tput setaf 1`

green=`tput setaf 2`

cyan=`tput setaf 6`

bold=`tput bold`

reset=`tput sgr0`

heading()
{

	echo

	echo "${cyan}==>${reset}${bold} $1${reset}"

}

success()
{

	echo

	echo "${green}==>${bold} $1${reset}"

}

error()
{

	echo

	echo "${red}==>${bold} Error: $1${reset}"

}

heading "Updating Ethereum Classic"

heading "Stopping processes"

pm2 stop all

heading "Flushing logs"

pm2 flush

rm -Rf ~/logs/*

rm -rf ~/.local/share/Trash/*

heading "Stopping pm2"

pm2 kill

heading "Killing remaining node processes"

echo `ps auxww | grep node | awk '{print $2}'`

kill -9 `ps auxww | grep node | awk '{print $2}'`

heading "Updating repos"

sudo apt-get clean

sudo add-apt-repository -y ppa:ethereum/ethereum

sudo add-apt-repository -y ppa:ethereum/ethereum-dev

sudo apt-get update -y

sudo apt-get upgrade -y

heading "Installing geth"

# install geth

cd /tmp

[ -e go-ethereum ] && sudo rm -rf go-ethereum

git clone https://github.com/ethereumproject/go-ethereum.git

cd go-ethereum

make all

cd build/bin

cp -b abigen bootnode disasm ethtest evm generators geth gethrpctest rlpdump ~/bin

heading "Updating etcstat.us client"

cd ~/bin/www

git pull

sudo npm update

success "geth was updated successfully"

heading "Restarting processes"

cd ~/bin

pm2 start processes.json
