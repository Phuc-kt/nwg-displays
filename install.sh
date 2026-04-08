#!/usr/bin/env bash

# nwg-displays installation script
# Supports: Arch Linux, Debian/Ubuntu, Fedora, openSUSE

PROGRAM_NAME="nwg-displays"
MODULE_NAME="nwg_displays"

# Detect distribution and install dependencies
install_dependencies() {
    echo "Detecting Linux distribution..."
    
    if [ -f /etc/arch-release ]; then
        echo "Arch Linux detected"
        sudo pacman -S --noconfirm python-build python-installer python-setuptools python-wheel
    elif [ -f /etc/debian_version ]; then
        echo "Debian/Ubuntu detected"
        sudo apt update
        sudo apt install -y python3-build python3-installer python3-setuptools python3-wheel
    elif [ -f /etc/fedora-release ]; then
        echo "Fedora detected"
        sudo dnf install -y python3-build python3-installer python3-setuptools python3-wheel
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "opensuse-leap" ]] || [[ "$ID" == "opensuse-tumbleweed" ]]; then
            echo "openSUSE detected"
            sudo zypper install -y python3-build python3-installer python3-setuptools python3-wheel
        else
            echo "Unknown distribution: $ID"
            echo "Please install dependencies manually:"
            echo "  - python-build"
            echo "  - python-installer"
            echo "  - python-setuptools"
            echo "  - python-wheel"
            exit 1
        fi
    else
        echo "Could not detect Linux distribution"
        echo "Please install dependencies manually:"
        echo "  - python-build"
        echo "  - python-installer"
        echo "  - python-setuptools"
        echo "  - python-wheel"
        exit 1
    fi
}

# Install dependencies first
install_dependencies

SITE_PACKAGES="$(python3 -c "import sysconfig; print(sysconfig.get_paths()['purelib'])")"
PATTERN="$SITE_PACKAGES/$MODULE_NAME*"

# Remove from site_packages
for path in $PATTERN; do
    if [ -e "$path" ]; then
        echo "Removing $path"
        rm -r "$path"
    fi
done

[ -d "./dist" ] && rm -rf ./dist

# Remove launcher scripts
filenames=("/usr/bin/nwg-displays" "/usr/bin/nwg-displays-apply" "/usr/bin/nwg-displays-toggle-wallpapers")

for filename in "${filenames[@]}"; do
  if [ -f "$filename" ]; then
      rm -f "$filename"
      echo "Removing -f $filename"
  fi
done

echo "Building package..."
python3 -m build --wheel --no-isolation

echo "Installing package..."
python3 -m installer dist/*.whl

echo "Installing desktop file and icons..."
install -Dm 644 -t "/usr/share/applications" "$PROGRAM_NAME.desktop"
install -Dm 644 -t "/usr/share/pixmaps" "$PROGRAM_NAME.svg"

echo "Installing documentation..."
install -Dm 644 -t "/usr/share/licenses/$PROGRAM_NAME" LICENSE
install -Dm 644 -t "/usr/share/doc/$PROGRAM_NAME" README.md

echo ""
echo "Installation complete!"
echo "You can now run: nwg-displays"