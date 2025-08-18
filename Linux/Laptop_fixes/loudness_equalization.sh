#!/bin/bash

# This script automates the installation of EasyEffects and downloads a collection of EasyEffects presets.
# After running this script, you will need to manually import the desired presets into EasyEffects.

echo "Starting EasyEffects and Presets setup..."

# --- Step 1: Install Flatpak if not already installed ---
# EasyEffects is primarily distributed as a Flatpak application.
# This step checks if Flatpak is installed and guides the user if it's not.
if ! command -v flatpak &> /dev/null
then
    echo "Flatpak is not installed. EasyEffects requires Flatpak."
    echo "Please install Flatpak first, then run this script again."
    echo "You can usually install it using: sudo apt install flatpak"
    echo "And then add the Flathub remote: flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
    exit 1
fi

# --- Step 2: Install EasyEffects ---
echo "Installing EasyEffects via Flatpak..."
flatpak install flathub com.github.wwmm.easyeffects -y

if [ $? -eq 0 ]; then
    echo "EasyEffects installed successfully."
else
    echo "Failed to install EasyEffects. Please check the error messages above."
    exit 1
fi

# --- Step 3: Install Git if not already installed ---
# Git is required to clone the GitHub repository.
if ! command -v git &> /dev/null
then
    echo "Git is not installed. It's required to download the presets."
    echo "Please install Git using: sudo apt install git"
    echo "Then run this script again."
    exit 1
fi

# --- Step 4: Download the EasyEffects Presets GitHub repository ---
# The presets will be downloaded into a folder named 'EasyEffects-Presets' in your current directory.
echo "Downloading EasyEffects Presets from GitHub..."
git clone https://github.com/Digitalone1/EasyEffects-Presets.git

if [ $? -eq 0 ]; then
    echo "EasyEffects Presets downloaded successfully to ./EasyEffects-Presets."
else
    echo "Failed to download EasyEffects Presets. Please check your internet connection or Git installation."
    exit 1
fi

echo ""
echo "Setup complete! Now, follow these steps to import the presets into EasyEffects:"
echo "1. Launch EasyEffects (you can find it in your applications menu)."
echo "2. In EasyEffects, go to the 'Output' tab (if you want to apply effects to your speakers/headphones)."
echo "3. On the left sidebar, under 'Presets', click the 'Import' button (it looks like a folder with an arrow pointing in)."
echo "4. Navigate to the 'EasyEffects-Presets' folder that was downloaded by this script (it's in the same directory where you ran this script)."
echo "5. Inside that folder, go to the 'Output' directory, then 'Digitalone1_Presets'."
echo "6. Select the desired preset file (e.g., 'Loudness Equalizer.json') and click 'Open'."
echo "7. The preset should now appear in your list of presets. Select it and click 'Load'."
echo "8. You can also enable 'Start Service at Login' in EasyEffects preferences to have it run automatically."
echo ""
echo "Enjoy your improved audio experience!"
