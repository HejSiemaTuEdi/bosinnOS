# bosinnOS Installation and Usage Guide

## Files Created

1. **bosinnOS-20251022.iso** - The main ISO file containing the bosinnOS system
2. **bosinnOS-installer.sh** - Linux installer script
3. **bosinnOS-installer.bat** - Windows installer script

## Using the ISO File

### Option 1: Burn to CD/DVD
1. Use any CD/DVD burning software
2. Select the `bosinnOS-20251022.iso` file
3. Burn to a CD or DVD
4. Boot from the disc

### Option 2: Create Bootable USB (Linux)
```bash
# Make installer executable
chmod +x bosinnOS-installer.sh

# Create bootable USB (requires root)
sudo ./bosinnOS-installer.sh --usb /dev/sdb --iso bosinnOS-20251022.iso
```

### Option 3: Create Bootable USB (Windows)
```cmd
# Run the Windows installer
bosinnOS-installer.bat --usb E: --iso bosinnOS-20251022.iso
```

### Option 4: Use in Virtual Machine
1. Create a new virtual machine
2. Set the ISO file as the boot device
3. Boot the virtual machine

## Installing bosinnOS to Hard Drive

### Linux Installation
```bash
# Install to a directory
./bosinnOS-installer.sh --target /opt/bosinnOS --iso bosinnOS-20251022.iso
```

### Windows Installation
```cmd
# Install to a directory
bosinnOS-installer.bat --target C:\bosinnOS --iso bosinnOS-20251022.iso
```

## What bosinnOS Includes

- **Instant Boot**: Boots directly to a shell prompt
- **Minimal System**: Lightweight Linux distribution
- **Bash Shell**: Standard Unix shell interface
- **Basic Commands**: Essential Linux commands available
- **Help System**: Type `help` for command reference

## System Requirements

- **Minimum RAM**: 64MB
- **Minimum Storage**: 100MB
- **Architecture**: x86_64
- **Boot Method**: BIOS or UEFI

## Boot Process

1. System boots instantly without configuration
2. Mounts essential filesystems
3. Starts bash shell immediately
4. No welcome messages or delays
5. Direct access to shell prompt

## Available Commands

- `ls` - List directory contents
- `cd` - Change directory
- `pwd` - Print working directory
- `cat` - Display file contents
- `cp` - Copy files
- `mv` - Move/rename files
- `rm` - Remove files
- `mkdir` - Create directory
- `ps` - Show running processes
- `top` - Show system processes
- `df` - Show disk usage
- `free` - Show memory usage
- `uname` - Show system information
- `date` - Show current date/time
- `help` - Show help information
- `exit` - Shutdown system

## Troubleshooting

### ISO Won't Boot
- Ensure your system supports the boot method (BIOS/UEFI)
- Try burning to a different CD/DVD
- Verify the ISO file isn't corrupted

### USB Won't Boot
- Ensure USB is properly formatted
- Check BIOS/UEFI boot order
- Try a different USB port

### Installation Issues
- Run installer as administrator/root
- Ensure sufficient disk space
- Check file permissions

## Support

For issues or questions:
1. Check this README first
2. Verify system requirements
3. Try different installation methods
4. Check file permissions and paths
