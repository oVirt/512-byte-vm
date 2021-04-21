#!/bin/bash

set -eao pipefail

if [ "$(which nasm | wc -l)" -ne 1 ]; then
  echo -e  "\033[0;31mPlease install nasm to build this VM.\033[0m" >&2
  exit 1
fi

if [ "$(which qemu-img | wc -l)" -ne 1 ]; then
  echo -e  "\033[0;31mPlease install qemu-img to build this VM.\033[0m" >&2
  exit 1
fi

if [ "$(which qemu-img | wc -l)" -ne 1 ]; then
  echo -e  "\033[0;31mPlease install qemu-img to build this VM.\033[0m" >&2
  exit 1
fi

if [ "$(which mkisofs | wc -l)" -ne 1 ]; then
  echo -e  "\033[0;31mPlease install mkisofs to build this VM.\033[0m" >&2
  exit 1
fi

if [ "$(which mkdosfs | wc -l)" -ne 1 ]; then
  echo -e  "\033[0;31mPlease install mkdosfs to build this VM.\033[0m" >&2
  exit 1
fi

nasm -o 512-byte-vm.raw 512-byte-vm.asm
qemu-img convert -c -f raw -O qcow2 512-byte-vm.raw 512-byte-vm.qcow2
qemu-img convert -f raw -O vmdk 512-byte-vm.raw 512-byte-vm.vmdk
qemu-img convert -f raw -O vdi 512-byte-vm.raw 512-byte-vm.vdi
qemu-img convert -f raw -O vpc 512-byte-vm.raw 512-byte-vm.vhd

rm -rf /tmp/512-byte-vm-iso/
mkdir -p /tmp/512-byte-vm-iso/
mkdosfs -C /tmp/512-byte-vm-iso/512-byte-vm.flp 1440
dd status=noxfer conv=notrunc if=512-byte-vm.raw of=/tmp/512-byte-vm-iso/512-byte-vm.flp
mkisofs -input-charset iso8859-1 -o 512-byte-vm.iso -b 512-byte-vm.flp /tmp/512-byte-vm-iso/
rm -rf /tmp/512-byte-vm-iso/
