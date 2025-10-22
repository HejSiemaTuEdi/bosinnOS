#!/bin/bash

# bosinnOS Installer Script
# Installs bosinnOS to a target directory or creates a bootable USB

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}    bosinnOS Installer v1.0     ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -t, --target DIR     Install bosinnOS to target directory"
    echo "  -u, --usb DEVICE     Create bootable USB on device (e.g., /dev/sdb)"
    echo "  -i, --iso FILE       Use specific ISO file"
    echo "  -h, --help           Show this help message"
    echo
    echo "Examples:"
    echo "  $0 --target /opt/bosinnOS"
    echo "  $0 --usb /dev/sdb"
    echo "  $0 --target /opt/bosinnOS --iso bosinnOS-20251022.iso"
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    local deps=("mount" "umount" "parted" "mkfs.fat" "syslinux")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing[*]}"
        echo "Please install the missing dependencies:"
        echo "sudo apt-get install parted dosfstools syslinux"
        exit 1
    fi
    
    print_status "All dependencies found"
}

# Function to install to directory
install_to_directory() {
    local target_dir="$1"
    local iso_file="$2"
    
    print_status "Installing bosinnOS to $target_dir..."
    
    # Create target directory
    mkdir -p "$target_dir"
    
    # Mount ISO
    local mount_point="/tmp/bosinnOS-mount"
    mkdir -p "$mount_point"
    mount -o loop "$iso_file" "$mount_point"
    
    # Copy files
    print_status "Copying bosinnOS files..."
    cp -r "$mount_point"/* "$target_dir/"
    
    # Unmount ISO
    umount "$mount_point"
    rmdir "$mount_point"
    
    # Set permissions
    chmod -R 755 "$target_dir"
    chmod +x "$target_dir/rootfs/init"
    chmod +x "$target_dir/rootfs/usr/bin/help"
    
    # Create symlinks
    ln -sf "$target_dir/rootfs/usr/bin/help" /usr/local/bin/bosinnOS-help
    
    print_status "bosinnOS installed successfully to $target_dir"
    echo "You can now:"
    echo "  - Access help: bosinnOS-help"
    echo "  - Boot from the ISO: $iso_file"
    echo "  - Use the files in: $target_dir"
}

# Function to create bootable USB
create_bootable_usb() {
    local usb_device="$1"
    local iso_file="$2"
    
    print_warning "This will erase all data on $usb_device"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled"
        exit 0
    fi
    
    print_status "Creating bootable USB on $usb_device..."
    
    # Unmount USB device
    umount "$usb_device"* 2>/dev/null || true
    
    # Create partition table and partition
    print_status "Creating partition table..."
    parted -s "$usb_device" mklabel msdos
    parted -s "$usb_device" mkpart primary fat32 1MiB 100%
    parted -s "$usb_device" set 1 boot on
    
    # Format partition
    print_status "Formatting partition..."
    mkfs.fat -F 32 "${usb_device}1"
    
    # Mount USB device
    local usb_mount="/tmp/bosinnOS-usb"
    mkdir -p "$usb_mount"
    mount "${usb_device}1" "$usb_mount"
    
    # Mount ISO
    local iso_mount="/tmp/bosinnOS-iso"
    mkdir -p "$iso_mount"
    mount -o loop "$iso_file" "$iso_mount"
    
    # Copy ISO contents
    print_status "Copying files to USB..."
    cp -r "$iso_mount"/* "$usb_mount/"
    
    # Unmount
    umount "$iso_mount"
    umount "$usb_mount"
    rmdir "$iso_mount" "$usb_mount"
    
    print_status "Bootable USB created successfully!"
    echo "You can now boot from the USB device: $usb_device"
}

# Main function
main() {
    print_header
    
    local target_dir=""
    local usb_device=""
    local iso_file="bosinnOS-20251022.iso"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--target)
                target_dir="$2"
                shift 2
                ;;
            -u|--usb)
                usb_device="$2"
                shift 2
                ;;
            -i|--iso)
                iso_file="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check if ISO file exists
    if [ ! -f "$iso_file" ]; then
        print_error "ISO file not found: $iso_file"
        exit 1
    fi
    
    # Check if running as root for USB operations
    if [ -n "$usb_device" ] && [ "$EUID" -ne 0 ]; then
        print_error "USB operations require root privileges"
        echo "Please run: sudo $0 $*"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Perform installation
    if [ -n "$target_dir" ]; then
        install_to_directory "$target_dir" "$iso_file"
    fi
    
    if [ -n "$usb_device" ]; then
        create_bootable_usb "$usb_device" "$iso_file"
    fi
    
    # If no options specified, show usage
    if [ -z "$target_dir" ] && [ -z "$usb_device" ]; then
        show_usage
    fi
    
    print_status "bosinnOS installer completed!"
}

# Run main function
main "$@"
