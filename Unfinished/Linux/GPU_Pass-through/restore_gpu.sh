#!/bin/bash
# Restore GPU back to Linux host from VFIO

set -e

echo "[+] Reverting GRUB to remove VFIO and IOMMU settings..."
sudo sed -i 's/ amd_iommu=on iommu=pt vfio-pci.ids=[^"]*//' /etc/default/grub

echo "[+] Updating GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "[+] Removing VFIO override..."
sudo rm -f /etc/modprobe.d/vfio.conf

echo "[+] Rebuilding initramfs..."
sudo update-initramfs -u

echo "[+] Done. Please reboot for changes to take effect."

