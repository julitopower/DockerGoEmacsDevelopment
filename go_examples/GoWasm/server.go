package main

import "fmt"
import "net/http"
import "os"
import "strconv"

func main() {
	port, err := strconv.ParseInt(os.Args[1], 10, 64)
	if err != nil {
		fmt.Println("Please provide a valid port number")
		os.Exit(1)
	}
	http.ListenAndServe("0.0.0.0:"+strconv.FormatInt(port, 10),
		http.FileServer(http.Dir(".")))
}
