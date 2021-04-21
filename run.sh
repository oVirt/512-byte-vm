#!/bin/bash

set -eao pipefail

nasm vm.asm
qemu-system-x86_64-spice --spice port=9000,password=test -drive file=vm,format=raw
exit $?