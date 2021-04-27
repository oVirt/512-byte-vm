#!/bin/bash

set -eao pipefail

if [ ! -f 512-byte-vm.raw ]; then
  echo -e  "\033[0;31mPlease run build.sh first.\033[0m" >&2
  exit 1
fi

if [ "$(which gocr | wc -l)" -ne 1 ]; then
  echo -e  "\033[0;31mPlease install gocr to run this test.\033[0m" >&2
  exit 1
fi

if [ "$(which qemu-system-x86_64 | wc -l)" -ne 1 ]; then
  echo -e "\033[0;31mPlease install qemu to run this test.\033[0m" >&2
  exit 1
fi

if [ "$(which nc | wc -l)" -ne 1 ]; then
  echo -e "\033[0;31mPlease install netcat to run this test.\033[0m" >&2
  exit 1
fi

if [ "$(which convert | wc -l)" -ne 1 ]; then
  echo -e "\033[0;31mPlease install imagemagick to run this test.\033[0m" >&2
  exit 1
fi

source ./functions.sh

function test_image {
  image=$1

  log "⚙️ Starting VM with ${image} image..."

  (
    qemu-system-x86_64 \
      -nographic \
      -serial mon:stdio \
      -drive file=512-byte-vm.${image},format=${image} \
      -monitor telnet::2000,server,nowait >/tmp/qemu.log
  ) &

  sleep 10
  echo 'screendump /tmp/screendump.ppm
quit' | nc localhost 2000 >/dev/null
  sleep 1
  echo -e "\033[2m"
  cat /tmp/qemu.log
  echo -e "\033[0m"
  convert /tmp/screendump.ppm ${image}.png

  log "⚙️ Performing OCR and evaluating results..."
  if [ $(gocr -m 4 /tmp/screendump.ppm 2>/dev/null | grep 'Hello World' | wc -l) -ne 1 ]; then
    error "❌ Test failed: the virtual machine did not print \"Hello World\" to the output when run."
    return 1
  fi
  success "✅ Test successful."
}

SUCCESS=1
for image in raw qcow2 vdi vmdk; do
  set +e
  run_with_check "Testing ${image} image..." test_image $image
  if [ "$?" -ne 0 ]; then
    SUCCESS=0
  fi
  set -e
done

if [ "${SUCCESS}" -eq "1" ]; then
  success "✅ All tests successful."
  exit 0
else
  error "❌ One or more tests failed."
  exit 1
fi
