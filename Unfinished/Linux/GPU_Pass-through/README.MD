# 🎮 Linux to Windows GPU Passthrough Toolkit (Kubuntu, NVIDIA)

This repo helps you configure **single GPU passthrough** from **Ubuntu Linux** to a **Windows 10/11 virtual machine (VM)** using **KVM/QEMU + VFIO**. Includes automation scripts to isolate and restore your NVIDIA GPU cleanly.

==This isn't working propperly, and needs to be revisited in the future==

---

## 📦 Contents

- `isolate_gpu.sh`: Automatically detects and isolates all NVIDIA GPU PCI IDs using VFIO.
- `restore_gpu.sh`: Restores GPU access back to the Linux host.
- Manual setup instructions for passthrough (Kubuntu + Windows).
- Reversion procedure if anything goes wrong.

---

## 🧰 Requirements

- Ubuntu-based distro with GRUB and initramfs-tools
- NVIDIA GPU (preferably duo-GPU setup)
- CPU + motherboard that supports:
  - VT-d / AMD-Vi (IOMMU)
  - UEFI boot
- libvirt, QEMU, virt-manager
- Windows ISO + [virtio-win ISO](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/)

---

## 🧠 Manual Setup Guide (Step-by-Step)

### 1. Enable Virtualization in BIOS

- Intel: Enable **VT-d**
- AMD: Enable **SVM / AMD-Vi**

---

### 2. Get NVIDIA PCI Device IDs

```bash
lspci -nn | grep -i nvidia
````

Example output:

```
01:00.0 3D controller [0302]: NVIDIA Corporation GA107M [GeForce RTX 3050 Ti Mobile] [10de:25a0]
```

---

### 3. Enable IOMMU + Isolate GPU via GRUB

Edit GRUB:

```bash
sudo nano /etc/default/grub
```

Add parameters:

```diff
-GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
+GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amd_iommu=on iommu=pt vfio-pci.ids=10de:25a0"
```

Update GRUB:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Create VFIO override:

```bash
echo -e "options vfio-pci ids=10de:25a0\nsoftdep nvidia pre: vfio-pci" | sudo tee /etc/modprobe.d/vfio.conf
```

Rebuild initramfs:

```bash
sudo update-initramfs -u
```

Reboot:

```bash
sudo reboot
```

---

### 4. Verify GPU Is Isolated

```bash
lspci -k | grep -A 2 -i nvidia
```

Expected:

```
Kernel driver in use: vfio-pci
```

---

### 5. Set Up Windows VM (in virt-manager)

* **Chipset**: Q35
* **Firmware**: UEFI
* Add the Windows ISO and `virtio-win.iso` as CD-ROMs
* Add **PCI Host Device** (your GPU)
* Optional: Add virtual audio and USB controller passthrough
* During Windows install:

  * Load `virtio` drivers from ISO (for disk/network)
  * After install, run `virtio-win-guest-tools.exe` from CD
  * Reboot and install **NVIDIA drivers** inside guest

---

## ⚙️ Script Automation

### `isolate_gpu.sh`

```bash
sudo ./isolate_gpu.sh
```

* Detects all NVIDIA GPU PCI IDs automatically
* Backs up GRUB
* Adds vfio-pci kernel args
* Creates `/etc/modprobe.d/vfio.conf`
* Updates GRUB and initramfs
* Prompts reboot

### `restore_gpu.sh`

```bash
sudo ./restore_gpu.sh
```

* Removes VFIO kernel args
* Deletes vfio override file
* Restores GPU access to host
* Updates GRUB and initramfs
* Prompts reboot

---

## 🧯 Reverting Passthrough Manually

1. Edit GRUB again:

```bash
sudo nano /etc/default/grub
```

Remove any:
`amd_iommu=on iommu=pt vfio-pci.ids=...`

2. Delete VFIO config:

```bash
sudo rm /etc/modprobe.d/vfio.conf
```

3. Rebuild initramfs:

```bash
sudo update-initramfs -u
```

4. Reboot:

```bash
sudo reboot
```

5. Check GPU driver:

```bash
lspci -k | grep -A 2 -i nvidia
```

Should show:

```
Kernel driver in use: nvidia
```

If not:

```bash
sudo apt install --reinstall nvidia-driver-<version>
```

---

## ⚠️ Known Warnings

* Host loses GPU output unless you have an **integrated GPU** or remote access (SSH/serial).
* Secure Boot **must be disabled**.
* Hybrid GPU (laptop) passthrough is fragile due to Optimus and bbswitch.
* VM performance may benefit from:

  * HugePages
  * CPU pinning
  * Dedicated USB controller
  * Looking Glass for seamless output

---

## 🧠 Useful Commands

List IOMMU groups:

```bash
find /sys/kernel/iommu_groups/ -type l
```

Check vfio status:

```bash
dmesg | grep -i vfio
```

Test QEMU config:

```bash
qemu-system-x86_64 --version
```
