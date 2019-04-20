# helpers to create mbr/uefi keys see:
- ./dokey.sh
- ./makengkey.sh

# key layout
- MBR Table
- First partiton has to be FAT32 with EFI(ESP) boot flag set.

# prereqs
```
sudo apt install grub-pc-bin grub-efi-ia32-bin grub-efi-amd64-bin
```

refs:
- https://github.com/ndeineko/grub2-bios-uefi-usb
