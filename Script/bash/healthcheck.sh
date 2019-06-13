#!/usr/bin/env bash

remote_url=$1
system_time=$(date +%s)
remote_time=$(curl --silent $remote_url)

if [ $? -ne 0 ]; then
  echo "Cannot curl the curl"
  exit 1
fi

time_diff=$(($system_time-$remote_time))
echo "Time difference is $time_diff"

if [[ $time_diff -lt -1 || $time_diff -gt 1 ]]; then
    echo "not ok"
    exit 1
fi

echo "ok"
exit 0
