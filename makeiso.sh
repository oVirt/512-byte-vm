#!/bin/bash

mkdir tmp/
nasm -f bin -o tmp/vm vm.asm
mkdosfs -C tmp/vm.flp 1440
dd status=noxfer conv=notrunc if=tmp/vm of=tmp/vm.flp
mkisofs -input-charset iso8859-1 -o vm.iso -b vm.flp tmp/
unlink tmp/vm
unlink tmp/vm.flp
rmdir tmp/