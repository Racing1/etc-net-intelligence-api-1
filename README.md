Ethereum Classic Network Intelligence API
============
[![Build Status][travis-image]][travis-url] [![dependency status][dep-image]][dep-url]

This is the backend service which runs along with Ethereum and tracks the network status, fetches information through JSON-RPC and connects through WebSockets to [etcstat.us](https://github.com/mikeyb/etcstat.us) to feed information. For full install instructions please read the [wiki](https://github.com/mikeyb/etc-net-intelligence-api/wiki/Network-Status-Client-Setup).

## Prerequisite
* geth
* node
* npm


## Installation

Fetch and run the build shell. This will install everything you need.

```bash
bash <(curl https://raw.githubusercontent.com/mikeyb/etc-net-intelligence-api/master/bin/build.sh)
```
## Installation as docker container (optional)

There is a `Dockerfile` in the root directory of the repository. Please read through the header of said file for
instructions on how to build/run/setup. Configuration instructions below still apply.

## Configuration

Configure the app modifying ~/bin/processes.json.

```json
"env":
	{
		"NODE_ENV"        : "production",
		"RPC_HOST"        : "localhost",
		"RPC_PORT"        : "8545",
		"LISTENING_PORT"  : "30303",
		"INSTANCE_NAME"   : "",
		"CONTACT_DETAILS" : "",
		"WS_SERVER"       : "ws://rpc.etcstat.us",
		"WS_SECRET"       : "your-super-secret-ws-key",
		"VERBOSITY"       : 2
	}
```

## Run

Run it using pm2:

```bash
cd ~/bin
pm2 start processes.json
```

## Updating

To update the API client use the following command:

```bash
~/bin/www/bin/update.sh
```

It will stop the current netstats client processes, automatically detect your ethereum implementation and version, update it to the latest develop build, update netstats client and reload the processes.

[travis-image]: https://travis-ci.org/mikeyb/etc-net-intelligence-api.svg
[travis-url]: https://travis-ci.org/mikeyb/etc-net-intelligence-api
[dep-image]: https://david-dm.org/mikeyb/etc-net-intelligence-api.svg
[dep-url]: https://david-dm.org/mikeyb/etc-net-intelligence-api