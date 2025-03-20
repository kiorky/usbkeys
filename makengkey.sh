#!/usr/bin/env bash
# variation of the original script to inject data on an already existing usbkey
# (eg Add our linuxes on a windows key to make a multiple OS bootable device)
set -e
if [[ -n $DEBUG ]];then set -x;fi
NO_MBR=${NO_MBR-}
NO_EFI=${NO_EFI-}
NO_ISOS="${NO_ISOS-}"
NO_GRUB="${NO_GRUB-}"
NO_MBR_GRUB="${NO_MBR_GRUB-${NO_MBR-$NO_GRUB}}"
NO_EFI_GRUB="${NO_EFI_GRUB-${NO_EFI-$NO_GRUB}}"
NO_DOS_LABEL="${NO_DOS_LABEL-1}"
NO_EFI32_GRUB="${NO_EFI32_GRUB-${NO_EFI-$NO_GRUB}}"
DOS_LABEL=${DOS_LABEL:-USBBOOT}
MOUNTED="$1"
EFIMOUNTED="$MOUNTED/efi/liveusb"
EFIMOUNTED="$MOUNTED/efi"
EFIMOUNTED="$MOUNTED"
DEVICE=$(mount |grep "$MOUNTED"|tail -n1|awk '{print $1}')
rsyncl="-rtPv  --modify-window=1"
rsynco="$rsyncl -c"
log() { echo "$@" >&2; }
vv() { log "$@";"$@"; }
die() { log "$@";exit 1; }
if [ ! -d "$MOUNTED" ];then die no dest;fi
if [ ! -e "$EFIMOUNTED" ];then mkdir -p "$EFIMOUNTED";fi
cd "$(dirname $(readlink -f $0))"
if [[ -z $NO_RSYNC ]];then
    if [[ -z $NO_ISOS ]];then
        rsync $rsyncl isos/      "$MOUNTED/isos/"
    fi
    rsync $rsynco boot.uefi/efi/    "$EFIMOUNTED/"
    rsync $rsynco boot.uefi/ "$MOUNTED/boot/" --exclude=efi
fi
rm -rf $MOUNTED/boot/efi
if [[ -z $DEVICE ]];then
    echo no device for $MOUNTED
    exit 1
fi
if [[ -z $NO_GRUB ]];then
    if [ -e $DEVICE ];then
        BLOCK="$(echo $DEVICE|sed -re "s/[1-9]+$//g")"
        BLOCKNUMBER="$(echo $DEVICE|sed -re "s/.*([1-9]+)$/\1/g")"
        GRUBBLOCK=${BLOCK}
        if ( sudo gdisk -l $BLOCK|grep -iq "gpt: present" );then
            BLOCKTYPE=gpt
            #GRUBBLOCK=${BLOCK}$(($BLOCKNUMBER ))
        else
            BLOCKTYPE=msdos
        fi
        if [[ -z $NO_EFI32_GRUB ]];then
            sudo grub-install --efi-directory=$EFIMOUNTED \
                --boot-directory=$MOUNTED/boot/ \
                --target=i386-efi --removable $GRUBBLOCK
        fi
        if [[ -z $NO_EFI_GRUB ]];then
            sudo grub-install --efi-directory=$EFIMOUNTED \
                --boot-directory=$MOUNTED/boot/ \
                --target=x86_64-efi --removable $GRUBBLOCK
        fi
        if [[ -z $NO_MBR_GRUB ]];then
            LANG=C sudo grub-install \
                --force --boot-directory=$MOUNTED/boot/ \
                --target=i386-pc --removable $GRUBBLOCK
        fi
        if [[ -z $NO_DOS_LABEL ]];then
            dosfslabel $DEVICE $DOS_LABEL
        fi
        sudo sed -i -r \
            -e "s/USBBOOT/${DOS_LABEL}/g" \
            -e "s/gpt2/${BLOCKTYPE}${BLOCKNUMBER}/g" \
            $MOUNTED/boot/grub/grub.cfg
    fi
    sudo rsync $rsynco --delete "$MOUNTED/boot/grub/" "$MOUNTED/boot/grub2/"
fi
# vim:set et sts=5 ts=4 tw=80:
