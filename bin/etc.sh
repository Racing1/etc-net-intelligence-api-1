#!/usr/bin/env bash

trap "exit" INT

IS_EC2=`curl -s http://instance-data.ec2.internal`

[ $IS_EC2 ] && IP=$(ec2metadata --public-ipv4)

[ ! $IS_EC2 ] && IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

echo "Public IP: $IP"

echo "Starting geth"

echo geth --rpc --bootnodes "enode://48e063a6cf5f335b1ef2ed98126bf522cf254396f850c7d442fe2edbbc23398787e14cd4de7968a00175a82762de9cbe9e1407d8ccbcaeca5004d65f8398d759@159.203.255.59:30303" --nat "extip:$IP"

geth --rpc --bootnodes "enode://48e063a6cf5f335b1ef2ed98126bf522cf254396f850c7d442fe2edbbc23398787e14cd4de7968a00175a82762de9cbe9e1407d8ccbcaeca5004d65f8398d759@159.203.255.59:30303" --nat "extip:$IP"