#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <cuda_binary>"
    exit 1
fi

BIN="$1"

if [ ! -f "$BIN" ]; then
    echo "Error: $BIN does not exist."
    exit 1
fi

echo "Dumping PTX..."
cuobjdump -ptx "$BIN" > "${BIN}_ptx.txt"

echo "Dumping SASS..."
cuobjdump -sass "$BIN" > "${BIN}_sass.txt"

echo "Done."
echo "PTX : ${BIN}_ptx.txt"
echo "SASS: ${BIN}_sass.txt"
