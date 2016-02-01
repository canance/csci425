#!/usr/bin/env bash
#title           :stop_server.sh
#description     :This script will stop a specified dev server.  If none are specified then it will start dev server 1, 2, and 3.
#author		 :Cory Nance
#date            :20160131
#version         :0.2    
#usage		 :bash stop_server.sh

MAX_SERVERS=3
if [ -z "$1" ]; then
	for i in `seq 1 $MAX_SERVERS`;
	do
		echo Stopping dev$i...
		~riak/riak/dev/dev$i/bin/riak stop
	done
else
	echo Stopping dev$1...
	~riak/riak/dev/dev$1/bin/riak stop

fi


