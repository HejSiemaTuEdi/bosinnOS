# bosinnOS - Java-based Linux Distribution

A custom Linux distribution with Java as the primary system programming language and user interface.

## Features

- Linux kernel as the foundation
- GNU tools integration
- Java-based shell and system utilities
- Java runtime environment
- Custom init system written in Java
- Java wrappers for GNU tools

## Project Structure

```
bosinnOS/
├── kernel/              # Linux kernel configuration and build
├── java-runtime/        # Java runtime environment
├── java-tools/          # Java-based system tools
├── init-system/         # Java-based init system
├── gnu-integration/     # GNU tools integration
├── build/               # Build scripts and configuration
└── docs/               # Documentation
```

## Building

1. Install dependencies (build-essential, kernel headers, etc.)
2. Run `./build/build.sh` to build the entire system
3. Create bootable image with `./build/create-image.sh`

## Usage

The system boots into a Bash shell where you can run Bash programs and access GNU tools 
