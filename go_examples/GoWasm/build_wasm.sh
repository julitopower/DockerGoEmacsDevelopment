#!/bin/bash

if [ $# -ne 1 ];
then
   echo "Error. Usage:"
   echo "build_wasm.sh filename"
   exit 1
else
    echo "Building Wasm application: $1"
fi

if [ ! -f wasm_exec.js ];
then
    echo "Copying wasm_exec.js from Go installation"
    cp "$(go env GOROOT)/misc/wasm/wasm_exec.js" .
fi

go build server.go
GOOS=js GOARCH=wasm go build -o main.wasm $1
exit 0
