# helpers to create mbr/uefi keys see:
- ./dokey.sh
- ./makengkey.sh

# key layout
- gparted -> gpt partition, 1 partition fat32,  flags boot+esp
- gdisk -> hybrid MBR

	```sh
	gdisk /dev/mydisk
		Command (? for help): r
		Recovery/transformation command (? for help): h
		Type from one to three GPT partition numbers, separated by spaces, to be added to the hybrid MBR, in sequence: 1
		Place EFI GPT (0xEE) partition first in MBR (good for GRUB)? (Y/N): y
		Set the bootable flag? (Y/N): y
		Recovery/transformation command (? for help): w
		Do you want to proceed? (Y/N): y
	```
- install key

    ```sh
    docker-compose build
    docker-compose run --rm app
    mount /dev/sda1 usbmount
    ./makengkey.sh /app/usbmount
    umount usbmount
    ```

refs:
- https://github.com/ndeineko/grub2-bios-uefi-usb

