#!/usr/bin/env bash
#!/usr/bin/env bash
# partition type gpt
# partition in 2 partitions in fat
# mark efi as bootable
# mount efi in /boot/efi
# think to use 7z to unpack bootmgr.efi from sources/1/install.wim
cd "$(dirname $0)"
C="$PWD"
MOUNTED=$(mount|grep "$C"|awk '{print $1}')
EFIMOUNTED=$(mount|grep "$C/boot/efi "|awk '{print $1}')
if [ "x${MOUNTED}" != "x" ];then
    echo noroot;exit 1
fi
efi=""
for i in ${@};do
    if [ "x${i}" = "xuefi" ] || [ "x${i}" = "xefi" ];then
        efi=1
    fi
done
c="$(date +"%F-%H%H%S")"
cd $MOUNTED
set -ex
tar cjvf boot-$c.tar.bz2 boot
rsync -Aazv $C/ $MOUNTED/
if [ "x$efi" != "x" ];then
    rsync -Aazv --delete "$C/boot.uefi/" "$MOUNTED/boot/"
    grub2-install --efi-directory="$C/boot/efi/"   --boot-directory="$C/boot/" --target=x86_64-efi --recheck --removable $MOUNTED
else
    rsync -Aazv --delete "$C/boot.mbr/" $MOUNTED/boot/
    rsync -Aazv $C/ $MOUNTED/
    grub2-install --boot-directory="$C/boot/" --target=i386-pc --recheck $MOUNTED
fi
cd /
if [ "x${EFIMOUNTED}" != "x" ];then
    umount $C/boot/efi
fi
umount $C
# vim:set et sts=5 ts=4 tw=80:
