#!/usr/bin/env bash
set -ex
cd "$(dirname $(readlink -f $0))"
for i in x86_64-efi i386-pc;do
    rsync -azv --delete /usr/lib/grub/$i/ boot.uefi/grub/$i/
done
# vim:set et sts=4 ts=4 tw=80:
