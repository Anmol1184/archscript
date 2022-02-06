#!/bin/bash
mkfs.fat -F32 /dev/sda1
#mkswap /dev/sda2
#swapon /dev/sda2
mkfs.btrfs /dev/sda2
mount /dev/sda2 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@var
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@.snapshots
umount /mnt

mount -o noatime,space_cache=v2,ssd,compress=zstd,discard=async,subvol=@ /dev/sda2 /mnt
# You need to manually create folder to mount the other subvolumes at
mkdir /mnt/{boot/efi,home,var,opt,tmp,.snapshots}

mount -o noatime,space_cache=v2,ssd,compress=zstd,discard=async,subvol=@home /dev/sda2 /mnt/home

mount -o noatime,space_cache=v2,ssd,compress=zstd,subvol=@opt /dev/sda2 /mnt/opt

mount -o noatime,space_cache=v2,ssd,compress=zstd,subvol=@tmp /dev/sda2 /mnt/tmp

mount -o noatime,space_cache=v2,ssd,compress=zstd,subvol=@.snapshots /dev/sda2 /mnt/.snapshots

mount -o noatime,space_cache=v2,ssd,compress=zstd,subvol=@var /dev/sda2 /mnt/var

# Mounting the boot partition at /boot folder
mount /dev/sda1 /mnt/boot/efi

pacstrap /mnt base linux-zen linux-firmware nano amd-ucode btrfs-progs

genfstab -U /mnt >> /mnt/etc/fstab


