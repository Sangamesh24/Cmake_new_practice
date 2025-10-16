#!/bin/bash
set -e  # Exit on error

# Move to project root (if not already there)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create and enter build directory
mkdir -p build
cd build

# Run cmake on the parent folder
cmake ..

# Build the firmware
make

echo "✅ Build output:"
ls -lh *.elf *.bin
