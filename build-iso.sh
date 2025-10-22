#!/bin/bash

# bosinnOS ISO Build Script
# Simple script to create a bootable ISO image

set -e

echo "bosinnOS ISO Builder"
echo "===================="
echo "Creating bootable ISO image for bosinnOS..."

# Create build directory
BUILD_DIR="build"
ISO_DIR="$BUILD_DIR/iso"
ISO_FILE="bosinnOS-$(date +%Y%m%d).iso"

echo "Creating build directory..."
mkdir -p "$BUILD_DIR"
mkdir -p "$ISO_DIR"/{boot,isolinux,images}

# Create basic ISO structure
echo "Setting up ISO structure..."

# Create isolinux configuration
cat > "$ISO_DIR/isolinux/isolinux.cfg" << 'EOF'
default bosinnOS
prompt 1
timeout 30

label bosinnOS
  menu label ^bosinnOS - Java-based Linux Distribution
  kernel /images/vmlinuz
  append initrd=/images/initrd.img
EOF

# Create root filesystem
echo "Creating root filesystem..."
mkdir -p "$ISO_DIR/rootfs"/{bin,sbin,etc,proc,sys,dev,tmp,var,usr/{bin,lib,share},lib64,home,root}

# Create essential files
cat > "$ISO_DIR/rootfs/etc/passwd" << 'EOF'
root:x:0:0:root:/root:/bin/sh
bosinnOS:x:1000:1000:bosinnOS User:/home/bosinnOS:/bin/sh
EOF

cat > "$ISO_DIR/rootfs/etc/group" << 'EOF'
root:x:0:
bosinnOS:x:1000:
EOF

cat > "$ISO_DIR/rootfs/etc/hostname" << 'EOF'
bosinnOS
EOF

# Create welcome message
cat > "$ISO_DIR/rootfs/etc/motd" << 'EOF'
Welcome to bosinnOS - Java-based Linux Distribution
=================================================

bosinnOS is a custom Linux distribution with Java as the primary
system programming language and user interface.

Features:
- Linux kernel foundation
- Java-based shell and utilities
- GNU tools integration
- Java runtime environment

For help, type 'help' in the Java shell.
EOF

# Create init script
cat > "$ISO_DIR/rootfs/init" << 'EOF'
#!/bin/sh

# bosinnOS Init Script
echo "Starting bosinnOS - Java-based Linux Distribution..."

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Set up environment
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export JAVA_HOME=/usr/java
export PATH=$JAVA_HOME/bin:$PATH

# Display welcome message
cat /etc/motd

# Start Java-based init system
echo "Starting Java init system..."
cd /usr/java-tools
java -cp classes:lib/* javaos.init.JavaInitSystem

# If Java init fails, fall back to shell
echo "Java init failed, starting shell..."
exec /bin/sh
EOF

chmod +x "$ISO_DIR/rootfs/init"

# Create dummy kernel and initramfs (for demonstration)
echo "Creating dummy kernel and initramfs..."
echo "dummy kernel" > "$ISO_DIR/images/vmlinuz"
echo "dummy initramfs" | gzip > "$ISO_DIR/images/initrd.img"

# Create ISO using available tools
echo "Creating ISO image..."

# Check for mkisofs or genisoimage
if command -v mkisofs &> /dev/null; then
    ISO_CMD="mkisofs"
elif command -v genisoimage &> /dev/null; then
    ISO_CMD="genisoimage"
else
    echo "mkisofs or genisoimage not found. Creating basic ISO structure..."
    # Create a basic directory structure for manual ISO creation
    echo "ISO structure created in $ISO_DIR"
    echo "To create the actual ISO, install mkisofs or genisoimage and run:"
    echo "mkisofs -o $ISO_FILE -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V \"bosinnOS\" $ISO_DIR"
    exit 0
fi

# Create ISO
$ISO_CMD -o "$ISO_FILE" \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -J -R \
    -V "bosinnOS" \
    "$ISO_DIR"

echo "bosinnOS ISO created successfully: $ISO_FILE"
echo "ISO size: $(du -h "$ISO_FILE" | cut -f1)"
echo ""
echo "To boot from this ISO:"
echo "1. Burn to CD/DVD or create bootable USB"
echo "2. Boot from the media"
echo "3. Enjoy bosinnOS!"
