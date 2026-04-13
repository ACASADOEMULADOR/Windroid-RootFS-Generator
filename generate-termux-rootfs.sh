#!/usr/bin/env bash

set -eu

cd "$(dirname "$(realpath "$0")")/termux-docker"

TERMUX_ARCH="${1:-x86_64}"
TERMUX_DOCKER__BOOTSTRAP_VERSION="2026.04.05-r1%2Bapt.android-7"
TERMUX_DOCKER__BOOTSTRAP_SRCURL="https://github.com/termux/termux-packages/releases/download/bootstrap-${TERMUX_DOCKER__BOOTSTRAP_VERSION}/bootstrap-${TERMUX_ARCH}.zip"
TERMUX_APP__PACKAGE_NAME="com.termux"
TERMUX_APP__DATA_DIR="/data/data/$TERMUX_APP__PACKAGE_NAME"
TERMUX__PREFIX_SUBDIR="usr"
TERMUX__ROOTFS="${TERMUX_APP__DATA_DIR}/files"
TERMUX__PREFIX="${TERMUX__ROOTFS}/${TERMUX__PREFIX_SUBDIR}"
TERMUX_DOCKER__ROOTFS="$(pwd)/termux-docker-rootfs"
TERMUX_DOCKER__TMPDIR="$(mktemp -d "/tmp/termux-docker-tmp.XXXXXXXX")"

echo "[*] Regenerating rootfs for ${TERMUX_ARCH}..."
rm -rf "${TERMUX_DOCKER__ROOTFS}"
mkdir -p "${TERMUX_DOCKER__ROOTFS}"

echo "[*] Downloading bootstrap..."
curl --fail --location --output "${TERMUX_DOCKER__TMPDIR}/bootstrap-${TERMUX_ARCH}.zip" "${TERMUX_DOCKER__BOOTSTRAP_SRCURL}"
mkdir -p "${TERMUX_DOCKER__ROOTFS}${TERMUX__PREFIX}"

echo "[*] Extracting bootstrap..."
unzip -q -d "${TERMUX_DOCKER__ROOTFS}${TERMUX__PREFIX}" "${TERMUX_DOCKER__TMPDIR}/bootstrap-${TERMUX_ARCH}.zip"
pushd "${TERMUX_DOCKER__ROOTFS}${TERMUX__PREFIX}/" > /dev/null
cat "${TERMUX_DOCKER__ROOTFS}${TERMUX__PREFIX}/SYMLINKS.txt" | while read -r line; do
    dest=$(echo "$line" | awk -F '←' '{ print $1 }');
    link=$(echo "$line" | awk -F '←' '{ print $2 }');
    ln -s "$dest" "$link";
done
popd > /dev/null
rm "${TERMUX_DOCKER__ROOTFS}${TERMUX__PREFIX}/SYMLINKS.txt"

echo "[*] Linking /system to \$PREFIX/opt/aosp..."
ln -sf "data/data/${TERMUX_APP__PACKAGE_NAME}/files/usr/opt/aosp" "${TERMUX_DOCKER__ROOTFS}/system"

echo "[*] Creating /system/etc/group..."
rm -rf "${TERMUX_DOCKER__ROOTFS}/system"
mkdir -p "${TERMUX_DOCKER__ROOTFS}/system/etc"
cat > "${TERMUX_DOCKER__ROOTFS}/system/etc/group" << 'EOF'
root:x:0:
system:!:1000:system
EOF

echo "[*] Creating /system/etc/hosts..."
cat > "${TERMUX_DOCKER__ROOTFS}/system/etc/hosts" << 'EOF'
127.0.0.1 localhost
::1 ip6-localhost
EOF

echo "[*] Creating /system/etc/passwd..."
cat > "${TERMUX_DOCKER__ROOTFS}/system/etc/passwd" << EOF
root:x:0:0:root:/:/system/bin/sh
system:x:1000:1000:system:${TERMUX__ROOTFS}/home:${TERMUX__PREFIX}/bin/login
EOF

echo "[*] Rootfs generation complete."
rm -rf "${TERMUX_DOCKER__TMPDIR}"

echo "Rootfs created at: ${TERMUX_DOCKER__ROOTFS}"
