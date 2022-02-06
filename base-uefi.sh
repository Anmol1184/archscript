#!/bin/bash
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.btrfs /dev/sda3
mount /dev/sda3 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@var
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@.snapshots
umount /mnt

mount -o noatime,space_cache=v2,ssd,compress=zstd,subvol=@ /dev/sda3 /mnt
# You need to manually create folder to mount the other subvolumes at
mkdir /mnt/{boot/efi,home,var,opt,tmp,.snapshots}

mount -o noatime,space_cache=v2,ssd,compress=zstd,subvol=@home /dev/sda3 /mnt/home

mount -o noatime,space_cache=v2,ssd,compress=zstd,subvol=@opt /dev/sda3 /mnt/opt

mount -o noatime,space_cache=v2,ssd,compress=zstd,subvol=@tmp /dev/sda3 /mnt/tmp

mount -o noatime,space_cache=v2,ssd,compress=zstd,subvol=@.snapshots /dev/sda3 /mnt/.snapshots

mount -o subvol=@var /dev/sda3 /mnt/var
# Mounting the boot partition at /boot folder
mount /dev/sda1 /mnt/boot/efi

pacstrap /mnt base linux linux-firmware nano amd-ucode btrfs-progs

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "anmol" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 anmol.localdomain anmol" >> /etc/hosts
echo root:password | chpasswd

# You can add xorg to the installation packages, I usually add it at the DE or WM install script
# You can remove the tlp package if you are installing on a desktop or vm

pacman -S grub efibootmgr networkmanager  network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-zen-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call  virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld sof-firmware nss-mdns acpid os-prober ntfs-3g xorg sddm openbox  lofi polybar gnome-terminal terminus-font

pacman -S  --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable sshd
systemctl enable avahi-daemon
# You can comment this command out if you didn't install tlp, see above
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid
systemctl enable sddm

useradd -m aj
echo aj:password | chpasswd
usermod -aG libvirt aj

echo "aj ALL=(ALL) ALL" >> /etc/sudoers.d/aj


printf "\e[1;32mDone! Add btrfs in MODULES=(), (nano /etc/mkinitcpio.conf) after this ( mkinitcpio -p linux ) Type exit, umount -a and reboot.\e[0m"


#nano /etc/mkinitcpio.conf
#Add btrfs in MODULES=()

