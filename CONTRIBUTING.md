# How do I contribute?

You want to contribute? Awesome! Let's go through what you need:

- [The Netwide Assembler](https://www.nasm.us/).
- A virtualization environment. We strongly recommend QEMU as it makes testing the easiest.
- A text editor. *(Please use Linux line endings and spaces for formatting.)*

You can edit the [512-byte-vm.asm](512-byte-vm.asm) file and then compile it. You can either run `./build.sh`, or do the steps manually. First of all, you'll need to assemble your code:

```
nasm -o 512-byte-vm.raw 512-bye-vm.asm 
```

This will produce a raw binary. Please note, this binary will **not** run on Linux, Windows, etc. because it is not in the right format. This is a binary which can be loaded directly from the boot sector of a drive by the BIOS and runs in 16 bit real mode. This is why you need a virtual machine to run it.

You can run the raw binary using QEMU like this:

```
qemu-system-x86_64 -nographic -serial mon:stdio -drive file=512-byte-vm.raw,format=raw
```

Alternatively, you can convert the raw disk image to your alternative virtualization format. For example:

```
qemu-img convert -f raw -O vmdk 512-byte-vm.raw 512-byte-vm.vmdk
```

This disk image can then be loaded in your virtualization environment.

You can run the automated tests by running `./test.sh` if you are in a Linux environment. (It works on WSL too!) This test will run the built raw image in a QEMU virtual machine, test the output, and capture the screen into the `screendump.png` file.

## Things to pay attention to

This disk image should fit in 512 bytes to stay within the boot sector. This means that your code needs to fit within the first 510 bytes as the magic bytes used by the BIOS to identify a bootable disk take up the last two bytes.

Please also comment your code as ASM code can be quite tricky to decypher without comments.

Finally, please keep in mind that this is meant to run in a virtualized environment and will only need to be compatible with a handful of platforms: QEMU, VirtualBox, etc. It will never need to run directly on physical hardware.

## Submitting your contribution

We want this project to be available to everyone, so we chose the [GPLv3 license](LICENSE.md) for this project. If you are ok with this you can submit a pull request [on GitHub](https://github.com/oVirt/512-byte-vm). 