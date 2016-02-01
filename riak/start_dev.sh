#!/usr/bin/env bash
#title           :start_server.sh
#description     :This script will start a specified dev server.  If none are specified then it will start dev server 1, 2, and 3.
#author		 :Cory Nance
#date            :20160131
#version         :0.2    
#usage		 :bash start_server.sh

MAX_SERVERS=3
ulimit -n 65536

if [ -z "$1" ]; then
	for i in `seq 1 $MAX_SERVERS`;
	do
		echo Starting dev$i...
		~riak/riak/dev/dev$i/bin/riak start
		if [ "$i" -ne "1" ]; then
			echo Joining cluster...
			~riak/riak/dev/dev$i/bin/riak-admin join -f dev1@127.0.0.1 > /dev/null
		fi
	done
else
	echo Starting dev$1...
	~riak/riak/dev/dev$1/bin/riak start
	if [ "$1" -ne "1" ]; then
		echo Joining cluster...
		~riak/riak/dev/dev$1/bin/riak-admin join -f dev1@127.0.0.1 > /dev/null
	fi
fi
