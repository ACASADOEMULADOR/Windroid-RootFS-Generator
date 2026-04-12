#!/bin/bash
set -e

mkdir -p "$DESTDIR/$PREFIX/bin"
mkdir -p "$DESTDIR/$PREFIX/etc"

# Try to find the box64 binary
if [ -f "box64" ]; then
    BOX64_BIN="box64"
elif [ -f "bin/box64" ]; then
    BOX64_BIN="bin/box64"
else
    BOX64_BIN=$(find . -maxdepth 3 -name "box64" -type f | head -n 1)
fi

if [ -z "$BOX64_BIN" ] || [ ! -f "$BOX64_BIN" ]; then
    echo "E: box64 binary not found in build directory!"
    echo "Contents of current directory:"
    ls -F
    exit 1
fi

echo "-- Installing box64 binary from $BOX64_BIN"
cp -f "$BOX64_BIN" "$DESTDIR/$PREFIX/bin/box64"
chmod 755 "$DESTDIR/$PREFIX/bin/box64"

# box64rc configuration
if [ -f "../system/box64.box64rc" ]; then
    cp -f "../system/box64.box64rc" "$DESTDIR/$PREFIX/etc/"
elif [ -f "system/box64.box64rc" ]; then
     cp -f "system/box64.box64rc" "$DESTDIR/$PREFIX/etc/"
else
    echo "-- W: box64.box64rc not found, skipping..."
fi
