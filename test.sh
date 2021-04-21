#!/bin/bash

nasm vm.asm
qemu-system-x86_64 vm
