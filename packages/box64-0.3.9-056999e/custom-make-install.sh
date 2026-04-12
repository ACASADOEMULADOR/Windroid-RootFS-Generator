#!/bin/bash
set -e

mkdir -p "$DESTDIR/$PREFIX/bin"
mkdir -p "$DESTDIR/$PREFIX/etc"

# Find box64 binary - CMake builds it in the current directory or bin/ subdirectory
BOX64_BIN=""
if [ -f "box64" ]; then
    BOX64_BIN="box64"
elif [ -f "bin/box64" ]; then
    BOX64_BIN="bin/box64"
else
    # Search in current directory and subdirectories
    BOX64_BIN=$(find . -maxdepth 2 -name "box64" -type f -executable 2>/dev/null | head -n 1)
fi

if [ -z "$BOX64_BIN" ] || [ ! -f "$BOX64_BIN" ]; then
    echo "E: box64 binary not found in build directory!"
    echo "Current directory: $(pwd)"
    echo "Contents of current directory:"
    ls -la
    echo "Contents of bin/ if exists:"
    ls -la bin/ 2>/dev/null || echo "No bin/ directory"
    exit 1
fi

echo "-- Installing box64 binary from: $BOX64_BIN"
cp -fv "$BOX64_BIN" "$DESTDIR/$PREFIX/bin/box64"
chmod 755 "$DESTDIR/$PREFIX/bin/box64"
ls -la "$DESTDIR/$PREFIX/bin/box64"

# box64rc configuration - try multiple locations
if [ -f "../system/box64.box64rc" ]; then
    echo "-- Installing box64.box64rc from ../system/"
    cp -f "../system/box64.box64rc" "$DESTDIR/$PREFIX/etc/"
elif [ -f "system/box64.box64rc" ]; then
    echo "-- Installing box64.box64rc from system/"
    cp -f "system/box64.box64rc" "$DESTDIR/$PREFIX/etc/"
elif [ -f "../../system/box64.box64rc" ]; then
    echo "-- Installing box64.box64rc from ../../system/"
    cp -f "../../system/box64.box64rc" "$DESTDIR/$PREFIX/etc/"
else
    echo "-- W: box64.box64rc not found, skipping..."
fi
