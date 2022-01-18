#!/bin/bash
while true
do
	var=''
	z=$(ps aux)
	while read -r z
	do
   		var=$var$(awk '{print "mem_usage{process=\""$11"\", pid=\""$2"\"}", $4z}');
	done <<< "$z"
	curl -X POST -H  "Content-Type: text/plain" --data "$var
	" http://localhost:9091/metrics/job/top/instance/machine
	sleep 1
done