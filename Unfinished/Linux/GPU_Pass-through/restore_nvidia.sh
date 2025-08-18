#!/bin/bash
# Restore NVIDIA GPU after VFIO passthrough use on Kubuntu hybrid systems
# Tested on NVIDIA + AMD laptops

set -e

echo "[1/7] Checking for vfio-pci binding..."
if lspci -nnk -d 10de: | grep -q "vfio-pci"; then
    GPU_PCI=$(lspci -nnk -d 10de: | grep -oP '^\S+')
    echo " - NVIDIA is bound to vfio-pci on $GPU_PCI, unbinding..."
    echo "$GPU_PCI" > /sys/bus/pci/drivers/vfio-pci/unbind || true
    modprobe nvidia || true
else
    echo " - No vfio-pci binding found. Continuing..."
fi

echo "[2/7] Removing vfio-pci from modprobe configs..."
sudo sed -i '/vfio-pci/d' /etc/modprobe.d/*.conf || true

echo "[3/7] Removing vfio kernel parameters from GRUB..."
sudo sed -i 's/vfio-pci.ids=[^ ]*//g' /etc/default/grub
sudo sed -i 's/amd_iommu=on//g' /etc/default/grub
sudo sed -i 's/intel_iommu=on//g' /etc/default/grub

echo "[4/7] Rebuilding initramfs..."
sudo update-initramfs -u

echo "[5/7] Updating GRUB..."
sudo update-grub

echo "[6/7] Ensuring NVIDIA drivers are installed..."
PKG=$(ubuntu-drivers devices | awk '/nvidia-driver-/ {print $1; exit}')
if [ -n "$PKG" ]; then
    echo " - Installing $PKG ..."
    sudo apt install --reinstall -y "$PKG"
else
    echo " - No recommended driver found, installing latest available..."
    sudo apt install --reinstall -y nvidia-driver-575
fi


echo "[7/7] Setting PRIME to NVIDIA..."
sudo prime-select nvidia

echo "Done. Please reboot now."

