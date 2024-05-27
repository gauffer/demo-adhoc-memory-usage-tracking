package main

import (
	"fmt"
	"net"
	"sync/atomic"
)

var (
	counter int64
)

func main() {
	listener, err := net.Listen("tcp", ":8080")
	if err != nil {
		fmt.Println("Error starting server:", err)
		return
	}
	defer listener.Close()
	fmt.Println("Server is listening on port 8080")
	for {
		conn, err := listener.Accept()
		if err != nil {
			fmt.Println("Error accepting connection:", err)
			continue
		}
		go handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	// Memory leak #1, verify that it leaks by calling $ lsof -i :8080
	// defer conn.Close()
	atomic.AddInt64(&counter, 1)
	currentCounter := atomic.LoadInt64(&counter)
	fmt.Printf("Counter: %d\n", currentCounter)

	_, err := conn.Write([]byte(fmt.Sprintf("Counter: %d\n", currentCounter)))
	if err != nil {
		fmt.Println("Error writing to connection:", err)
		return
	}

	// Memory leak #2. Goroutine leak
	go func() {
		ch := make(chan struct{})
		<-ch // Will wait forever
	}()
}
