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

if [ "$(which mkisofs | wc -l)" -ne 1 ]; then
  echo -e  "\033[0;31mPlease install mkisofs to build this VM.\033[0m" >&2
  exit 1
fi

if [ "$(which mkdosfs | wc -l)" -ne 1 ]; then
  echo -e  "\033[0;31mPlease install mkdosfs to build this VM.\033[0m" >&2
  exit 1
fi

source ./functions.sh

function create_iso {
  echo -e "\033[2m"
  rm -rf /tmp/512-byte-vm-iso/
  mkdir -p /tmp/512-byte-vm-iso/
  mkdosfs -C /tmp/512-byte-vm-iso/512-byte-vm.flp 1440
  dd status=noxfer conv=notrunc if=512-byte-vm.raw of=/tmp/512-byte-vm-iso/512-byte-vm.flp
  mkisofs -input-charset iso8859-1 -o 512-byte-vm.iso -b 512-byte-vm.flp /tmp/512-byte-vm-iso/
  rm -rf /tmp/512-byte-vm-iso/
  echo -e "\033[0m"
}

set -e
SUCCESS=1
run_with_check "Assembling..." nasm -o 512-byte-vm.raw 512-byte-vm.asm
if [ $? -ne 0 ]; then
  error "❌ Build failed."
  exit 1
fi
run_with_check "Creating QCOW2..." qemu-img convert -c -f raw -O qcow2 512-byte-vm.raw 512-byte-vm.qcow2
if [ $? -ne 0 ]; then
  SUCCESS=0
fi
run_with_check "Creating VMDK..." qemu-img convert -f raw -O vmdk 512-byte-vm.raw 512-byte-vm.vmdk
if [ $? -ne 0 ]; then
  SUCCESS=0
fi
run_with_check "Creating VDI..." qemu-img convert -f raw -O vdi 512-byte-vm.raw 512-byte-vm.vdi
if [ $? -ne 0 ]; then
  SUCCESS=0
fi
run_with_check "Creating VHD..." qemu-img convert -f raw -O vpc 512-byte-vm.raw 512-byte-vm.vhd
if [ $? -ne 0 ]; then
  SUCCESS=0
fi
run_with_check "Creating ISO..." create_iso
if [ $? -ne 0 ]; then
  SUCCESS=0
fi
if [ "${SUCCESS}" -eq 1 ]; then
  success "✅ Build successful."
else
  error "❌ Build failed."
  exit 1
fi
