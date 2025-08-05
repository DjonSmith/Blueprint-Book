#!/bin/bash
# Automatically isolate all NVIDIA GPUs for VFIO passthrough on Kubuntu

set -e

echo "[+] Detecting NVIDIA GPU PCI IDs..."
PCI_IDS=$(lspci -nn | grep -i 'nvidia' | grep -oP '\[\K[0-9a-f]{4}:[0-9a-f]{4}(?=\])' | sort -u | tr '\n' ',' | sed 's/,$//')

if [[ -z "$PCI_IDS" ]]; then
    echo "[-] No NVIDIA GPU PCI IDs found. Exiting."
    exit 1
fi

echo "[+] Found PCI IDs: $PCI_IDS"

echo "[+] Backing up /etc/default/grub..."
sudo cp /etc/default/grub "/etc/default/grub.bak.$(date +%Y%m%d_%H%M%S)"

echo "[+] Editing GRUB to enable IOMMU and VFIO for GPU(s)..."
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ amd_iommu=on iommu=pt vfio-pci.ids='"$PCI_IDS"'"/' /etc/default/grub

echo "[+] Updating GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "[+] Creating VFIO override config..."
echo -e "options vfio-pci ids=$PCI_IDS\nsoftdep nvidia pre: vfio-pci" | sudo tee /etc/modprobe.d/vfio.conf

echo "[+] Rebuilding initramfs..."
sudo update-initramfs -u

echo "[+] Done. Please reboot for changes to take effect."

