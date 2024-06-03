# Demo of Adhoc Memory Usage Tracking

Track and visualize memory usage in the Go application.

We use a bash script to track memory usage by reading VmRSS from `/proc/<pid>/status`. 

## Limitations

- VmRSS measures only physical memory, excluding shared memory, leading to potential underestimation.
- The script captures data every second, missing rapid memory fluctuations.
- If the process ends, logging stops, losing critical pre-termination data.

## Prerequisites

- Go 1.20
- Python 3.10
- Python libraries: `pandas`, `matplotlib`
- k6 for load testing

## Installation

Clone the repo.

Install Python deps.
```
python3.10 -m venv venv
source venv/bin/activate
pip install pandas matplotlib
```

## Usage

```bash
./run_all.sh "go run cmd/server_http"
python3 plot_mem.py
open out/memory_usage_plot_normalized.png
```

### Example Output

The graph shows memory rising from 5MB to 500MB in 10 seconds under 20,000 RPS. This intentional goroutine leak causes linear memory growth, a common symptom of memory leaks.

![Memory Usage](bad.png)


## Explanation of `run_all.sh`

1. Start the Go server and retrieve its PID.
2. Run memory tracking and load tests using `k6`.
3. Stop the server and save memory usage data.

### Hardcoded Port

The server must run on a hardcoded port: **8080**.
Appending a channel to a slice increases memory usage slightly since it only adds a reference to the channel, which is just a few bytes. This impact is negligible.

```sh
start_go_server() {
    $go_server_command > /dev/null 2>&1 &
    # go_server_pid=$!
    sleep 2  # ensure the server starts
    server_pid=$(lsof -i :8080 | awk '/LISTEN/ {print $2}' | head -n 1)
}
```
**Note:** To change the port, update the `lsof -i :8080` command or extend the script to accept the port as an argument.

With `go run`, `$go_server_pid` captures the PID of the `go run` process, the PID from `lsof -i :8080` will be different.



## Memory Leak
```go
...
var (
	counter  int64
	channels []chan struct{}
)
...
go func() {
    ch := make(chan struct{})
    channels = append(channels, ch)
    <-ch // Will wait forever
}()
...
```

### Explanation

**Appending to the `channels` slice:**

Appending a channel to a slice increases memory usage slightly since it only adds a reference to the channel, which is just a few bytes. This impact is negligible.
```go
channels = append(channels, ch)
```

**Impact of `var channels []chan struct{}` on Memory Leak:**

The channels slice has minimal impact on memory. Adding channels grows the slice, but the references are small compared to the memory used by goroutines. The slice's memory use is proportional to its references, while goroutines dominate memory usage.

**Receiving from the channel (`<-ch`):**

The major memory leak is caused by <-ch operations
```go
<-ch // Will wait forever
```
