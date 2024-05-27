package main

import (
	"fmt"
	"net/http"
	"sync/atomic"
)

var (
	counter  int64
	channels []chan struct{}
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		atomic.AddInt64(&counter, 1)
		currentCounter := atomic.LoadInt64(&counter)
		fmt.Printf("Counter: %d\n", currentCounter)

		_, err := fmt.Fprintf(w, "Counter: %d\n", currentCounter)
		if err != nil {
			fmt.Println("Error writing to response:", err)
			return
		}

		// Goroutine leak (intentionally)
		go func() {
			ch := make(chan struct{})
			channels = append(channels, ch)
			<-ch // Will wait forever
		}()
	})

	fmt.Println("Server is listening on port 8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		fmt.Println("Error starting server:", err)
	}
}
