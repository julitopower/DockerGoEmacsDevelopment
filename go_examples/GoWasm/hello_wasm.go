package main

import "fmt"
import "syscall/js"
import "strconv"

func add(a int64, b int64) string {
	return fmt.Sprintf("%d", a+b)
}

func read(v js.Value) string {
	return js.Global().Get("document").
		Call("getElementById", v.String()).
		Get("value").String()
}

func set(element string, value string) {
	js.Global().Get("document").Call("getElementById", element).Set("value", value)
}

func main() {
	// We want this channel to block and keep the webasm application
	// alive
	c := make(chan struct{})
	fmt.Println("Golang Webasm application running...")

	// Register a callback that can be called from javascript
	add_cb := func(i []js.Value) {
		in1, _ := strconv.ParseInt(read(i[0]), 10, 64)
		in2, _ := strconv.ParseInt(read(i[1]), 10, 64)
		res := add(in1, in2)
		set(i[2].String(), res)
	}
	js.Global().Set("add", js.NewCallback(add_cb))

	// Block
	<-c
}
