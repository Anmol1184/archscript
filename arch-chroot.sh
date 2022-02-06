
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

pacman -S grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-zen-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld sof-firmware nss-mdns acpid os-prober ntfs-3g xorg sddm openbox lofi polybar nautilus gnome-terminal terminus-font xf86-video-amdgpu pulseaudio firefox

#pacman -S  --noconfirm xf86-video-amdgpu
#pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
#systemctl enable sshd
systemctl enable avahi-daemon
# You can comment this command out if you didn't install tlp, see above
systemctl enable reflector.timer
systemctl enable fstrim.timer
#systemctl enable libvirtd
#systemctl enable firewalld
#systemctl enable acpid
systemctl enable sddm

useradd -m aj
echo aj:password | chpasswd
usermod -aG wheel aj

echo "aj ALL=(ALL) ALL" >> /etc/sudoers.d/aj


printf "\e[1;32mDone! Add btrfs in MODULES=(), (nano /etc/mkinitcpio.conf) after this ( mkinitcpio -p linux ) Type exit, umount -a and reboot.\e[0m"


#nano /etc/mkinitcpio.conf
#Add btrfs in MODULES=()