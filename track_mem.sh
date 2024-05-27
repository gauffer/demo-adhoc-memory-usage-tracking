#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <pid> <output_file>"
    exit 1
fi

pid=$1
output_file=$2
duration=13 # in seconds

if ! ps -p $pid > /dev/null; then
    echo "Process with PID $pid not found."
    exit 1
fi

get_memory_usage() {
    grep VmRSS /proc/$pid/status 2>/dev/null | awk '{print $2}'
}

echo "Timestamp,VmRSS_KB" > $output_file

end_time=$((SECONDS + duration))
while [ $SECONDS -lt $end_time ]; do
    mem_usage=$(get_memory_usage)
    timestamp=$(date +%s)
    if [ -n "$mem_usage" ]; then
        echo "${timestamp},${mem_usage}" >> $output_file
    else
        echo "Process with PID $pid has terminated."
        break
    fi
    sleep 1
done

echo "Memory tracking completed. Data saved to $output_file."

