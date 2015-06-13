#!/usr/bin/env bash
# EFI:
# partition type gpt
# partition in 2 partitions in FAT32
# mark efi as bootable
# mount partition
# mount efi in $c/boot/efi
# think to use 7z to unpack bootmgr.efi from sources/1/install.wim
#
# MSDOS:
# partition a big partition with FAT32
# mount parititon
#
# USAGE:
#  SEE $USAGE
cd "$(dirname $0)"
C="$(pwd)"
chrono="$(date +"%F-%H%H%S")"
USAGE="$0 key_mountpath [ uefi | mbr ] [ umount ]"
mounted="$1"
EFIMOUNTED="${MOUNTED}/boot/efi"
cd "${MOUNTED}"
MOUNTED="$(pwd)"
efi=""
mbr=""
doumount=""
shift
for i in ${@};do
    if [ "x${i}" = "xuefi" ] || [ "x${i}" = "xefi" ];then
        efi=1
    fi
    if [ "x${i}" = "xmsdos" ] || [ "x${i}" = "xmbr" ];then
        mbr=1
    fi
    if [ "x${i}" = "xumount" ];then
        doumount=1
    fi     
done
if [ "x$efi" != "x" ] && [ "x$mbr" != "x" ];then
    echo "$USAGE";exit 1
fi
if [ "x$efi" = "x" ] && [ "x$mbr" = "x" ];then
    echo "$USAGE";exit 1
fi
if [ "X${MOUNTED}" != "x${C}" ];then
    echo "ORIG $C"
fi
echo "MOUNTED $MOUNTED"
echo "EFIMOUNTED if applicable: $EFIMOUNTED"
nocopy=""
set -ex
if [ "x${MOUNTED}" = "x${C}" ];then
    nocopy="1"
    echo "WARNING: no copy, using key directly"
fi
if [ "x${MOUNTED}" = "x" ] || [ ! -d "${MOUNTED}" ] ;then
    echo key not mounted;exit 1
fi
cd $MOUNTED
if [ -e boot ];then tar cjvf "boot-${chrono}.tar.bz2" boot;fi
if [ "x${nocopy}" = "x" ];then rsync -Aazv $C/ $MOUNTED/;fi
if [ "x$efi" != "x" ];then
    rsync -Aazv --delete "$MOUNTED/boot.uefi/" "$MOUNTED/boot/"
    grub2-install --efi-directory="$MOUNTED/boot/efi/"   --boot-directory="$MOUNTED/boot/" --target=x86_64-efi --recheck --removable $MOUNTED
fi
if [ "x$mbr" != "x" ];then
    rsync -Aazv --delete "$MOUNTED/boot.mbr/" $MOUNTED/boot/
    grub2-install --boot-directory="$MOUNTED/boot/" --target=i386-pc --recheck $MOUNTED
fi
cd /
if [ "x${doumount}" != "x" ];then
    if [ "x${EFIMOUNTED}" != "x" ];then
        umount $MOUNTED/boot/efi
    fi
    umount $MOUNTED
fi
# vim:set et sts=5 ts=4 tw=80:
