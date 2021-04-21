# The 512-byte VM (Cloud native!)

This is a virtual machine that fits in 512 bytes (the boot sector).

## Why?!

Because when you test integration with virtualization systems such as [oVirt](https://www.ovirt.org/) (hint, hint), you often need a VM image to upload. If you have to run dozens or hundreds of test cases you don't want to be uploading GB-sized images.

## How?

Very much simplified, the first thing that loads when a computer, or a VM starts is the BIOS (or UEFI in newer systems). The BIOS provides some very basic functions, such as being able to print to the screen conveniently.

At any rate, the BIOS loads the boot loader from the MBR on the disk (first 512 bytes). UEFI is much smarter, but let's not deal with that right now. The MBR is a set of purely machine instructions that will be run pretty much as it is. This is different from how operating systems load binaries such as EXE files or ELF binaries, since those contain a header and a bunch of other information. The only requirement for the boot sector code is that it must end in `0xAA55` and the BIOS will happily execute it.

So, we compile [vm.asm](vm.asm) using the [NASM assembler](https://www.nasm.us/) and that's it, that's our disk image:

```
nasm vm.asm
```

Beautiful, raw data, right on the disk. You can run it directly using qemu:

```
qemu-system-x86_64-spice -drive file=vm,format=raw
qemu-system-x86_64-spice -boot d -cdrom vm.iso
```

Alternatively, you can convert it to various formats using `qemu-img`:

```
qemu-img convert -c -f raw -O qcow2 image image.qcow2
qemu-img convert -c -f raw -O vmdk image image.vmdk
```