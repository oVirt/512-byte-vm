# The 512-byte VM (Cloud native!)

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/ovirt/512-byte-vm?style=for-the-badge)](https://github.com/ovirt/512-byte-vm/releases)
[![GitHub license](https://img.shields.io/github/license/ovirt/512-byte-vm?style=for-the-badge)](https://github.com/ovirt/512-byte-vm/blob/main/LICENSE.md)
[![GitHub branch checks state](https://img.shields.io/github/workflow/status/ovirt/512-byte-vm/Build,%20Test,%20Release?style=for-the-badge)](https://github.com/oVirt/512-byte-vm/actions)

This is a virtual machine that fits in 512 bytes (the boot sector).

## Why?!

Because when you test integration with virtualization systems such as [oVirt](https://www.ovirt.org/) (hint, hint), you often need a VM image to upload. If you have to run dozens or hundreds of test cases you don't want to be uploading GB-sized images.

## Can I use it?

Sure! Go grab it from the [releases section](https://github.com/ovirt/512-byte-vm/releases)! We have raw, QCOW2, VDI, VMDK, VHD and ISO images.

## How?

Very much simplified, the first thing that loads when a computer, or a VM starts is the BIOS (or UEFI in newer systems). The BIOS provides some very basic functions, such as being able to print to the screen conveniently.

At any rate, the BIOS loads the boot loader from the MBR on the disk (first 512 bytes). UEFI is much smarter, but let's not deal with that right now. The MBR is a set of purely machine instructions that will be run pretty much as it is. This is different from how operating systems load binaries such as EXE files or ELF binaries, since those contain a header and a bunch of other information. The only requirement for the boot sector code is that it must end in `0xAA55` and the BIOS will happily execute it.

So, we compile [512-byte-vm.asm](512-byte-vm.asm) using the [NASM assembler](https://www.nasm.us/) and that's it, that's our disk image:

```
nasm -o 512-byte-vm.raw 512-byte-vm.asm
```

Beautiful, raw data, right on the disk. You can run it directly using qemu:

```
qemu-system-x86_64 -drive file=512-byte-vm.raw,format=raw
```

Alternatively, you can convert it to various formats using `qemu-img`:

```
qemu-img convert -c -f raw -O qcow2 512-byte-vm.raw 512-byte-vm.qcow2
qemu-img convert -f raw -O vmdk 512-byte-vm.raw 512-byte-vm.vmdk
```

Alternatively, you could also use the [build script](build.sh).

## Where can I learn more?

We didn't come up with this on our own. Here are a few resources that should get you started:

- [The OSDev Wiki](https://wiki.osdev.org/Main_Page) contains a wealth of material in case you want to write your own OS. The [Roll Your Own Bootloader](https://wiki.osdev.org/Rolling_Your_Own_Bootloader) section is especially useful if you want to do something similar.
- [The Interrupt Jump Table](http://www.ctyme.com/intr/int.htm) contains an index of several (older) interrupts that can be used to interact with hardware.
- [This page](http://ref.x86asm.net/coder32.html) contains the x86 CPU opcodes that the ASM instructions compile to.

## Can I contribute?

Sure! [Here's the detailed guide on how to do that!](CONTRIBUTING.md)
