#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <go_server_command>"
    exit 1
fi

go_server_command=$1

start_go_server() {
    $go_server_command > /dev/null 2>&1 &
    go_server_pid=$!
    sleep 2  # ensure the server starts
    server_pid=$(lsof -i :8080 | awk '/LISTEN/ {print $2}' | head -n 1)
}

stop_go_server() {
    if [ -n "$server_pid" ]; then
        kill $server_pid
        wait $server_pid 2>/dev/null
    fi
}

start_memory_tracking() {
    ./track_mem.sh $1 $2 &
    mem_tracking_pid=$!
}

scenarios=(
    "k6_scenarios/load_test_100.js out/memory_usage_100.csv"
    "k6_scenarios/load_test_1000.js out/memory_usage_1000.csv"
    "k6_scenarios/load_test_10000.js out/memory_usage_10000.csv"
    "k6_scenarios/load_test_20000.js out/memory_usage_20000.csv"
)

for scenario in "${scenarios[@]}"; do
    scenario_args=($scenario)
    script=${scenario_args[0]}
    output_file=${scenario_args[1]}

    echo "Running $script..."

    stop_go_server

    start_go_server

    start_memory_tracking $server_pid $output_file

    k6 run $script

    wait $mem_tracking_pid

    echo "Completed $script. Data saved to $output_file."
done

stop_go_server

