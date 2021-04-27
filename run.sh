#!/bin/bash

set -eao pipefail

if [ ! -f 512-byte-vm.raw ]; then
  echo "Please run build.sh first." >&2
  exit 1
fi

qemu-system-x86_64 -nographic -serial mon:stdio -drive file=512-byte-vm.raw,format=raw
