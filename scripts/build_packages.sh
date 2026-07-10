#!/bin/bash
# ============================================================
# luci-app-openvohive IPK/APK 打包脚本 (noarch, 通用)
# 纯 shell 构建，不依赖外部 SDK 下载，稳定可复现。
# ============================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT/dist}"
PKG_VERSION="${PKG_VERSION:-2.1.1}"
PKG_RELEASE="${PKG_RELEASE:-1}"

PKG="luci-app-openvohive"
LUCI_DIR="$REPO_ROOT/luci-app-openvohive"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

mkdir -p "$OUTPUT_DIR"

# ============================================================
# 构建 IPK (debian-binary + control.tar.gz + data.tar.gz)
# ============================================================
build_ipk() {
    log "构建 $PKG IPK (noarch)..."

    local CONTROL_DIR="$OUTPUT_DIR/${PKG}_${PKG_VERSION}-${PKG_RELEASE}_all"
    mkdir -p "$CONTROL_DIR/control"

    cat > "$CONTROL_DIR/control/control" <<EOF
Package: $PKG
Version: ${PKG_VERSION}-${PKG_RELEASE}
Architecture: all
Section: luci
Priority: optional
Maintainer: OpenVoHive <koudejun@live.com>
Description: LuCI support for Open-VoHive 4G/5G modem manager
Depends: libc, luci-base, curl
Source: https://github.com/6106757-lab/luci-app-openvohive
License: Apache-2.0
EOF

    cat > "$CONTROL_DIR/control/postinst" <<'SCRIPT'
#!/bin/sh
if [ -z "${IPKG_INSTROOT}" ]; then
	mkdir -p /opt/openvohive/data /opt/openvohive/logs /opt/openvohive/bin /tmp/openvohive/tasks
	/etc/init.d/openvohive enable 2>/dev/null || true
	/etc/init.d/rpcd reload >/dev/null 2>&1 || /etc/init.d/rpcd restart >/dev/null 2>&1 || true
fi
exit 0
SCRIPT
    chmod 0755 "$CONTROL_DIR/control/postinst"

    cat > "$CONTROL_DIR/control/prerm" <<'SCRIPT'
#!/bin/sh
if [ -z "${IPKG_INSTROOT}" ]; then
	/etc/init.d/openvohive stop 2>/dev/null || true
	/etc/init.d/openvohive disable 2>/dev/null || true
	killall -9 openvohive 2>/dev/null || true
fi
exit 0
SCRIPT
    chmod 0755 "$CONTROL_DIR/control/prerm"

    cp -a "$LUCI_DIR/root/." "$CONTROL_DIR/"

    cd "$OUTPUT_DIR"
    local IPK_NAME="${PKG}_${PKG_VERSION}-${PKG_RELEASE}_all.ipk"

    echo "2.0" > "$CONTROL_DIR/debian-binary"

    cd "$CONTROL_DIR/control"
    tar czpf "$OUTPUT_DIR/${IPK_NAME}.control.tar.gz" ./*
    cd "$CONTROL_DIR"
    rm -rf control
    tar czpf "$OUTPUT_DIR/${IPK_NAME}.data.tar.gz" --exclude=debian-binary ./*
    rm -f debian-binary

    cd "$OUTPUT_DIR"
    tar czpf "$IPK_NAME" \
        --owner=0 --group=0 \
        ./${PKG}_*/debian-binary \
        ./${PKG}_*/control.tar.gz \
        ./${PKG}_*/data.tar.gz 2>/dev/null || {
        echo "2.0" > debian-binary
        cp "${IPK_NAME}.control.tar.gz" control.tar.gz
        cp "${IPK_NAME}.data.tar.gz" data.tar.gz
        tar czpf "$IPK_NAME" debian-binary control.tar.gz data.tar.gz
        rm -f debian-binary control.tar.gz data.tar.gz
    }

    rm -rf "${CONTROL_DIR}" "${IPK_NAME}.control.tar.gz" "${IPK_NAME}.data.tar.gz"
    log "IPK 已生成: $OUTPUT_DIR/$IPK_NAME ($(du -h "$OUTPUT_DIR/$IPK_NAME" | cut -f1))"
}

# ============================================================
# 构建 APK (新 OpenWrt 包管理格式: tar.gz + .pkginfo)
# ============================================================
build_apk() {
    log "构建 $PKG APK (noarch)..."

    local PKG_DIR="$OUTPUT_DIR/${PKG}_${PKG_VERSION}-${PKG_RELEASE}_all"
    mkdir -p "$PKG_DIR"

    cp -a "$LUCI_DIR/root/." "$PKG_DIR/"

    cat > "$PKG_DIR/.pkginfo" <<EOF
name = $PKG
version = ${PKG_VERSION}-${PKG_RELEASE}
arch = all
description = LuCI support for Open-VoHive 4G/5G modem manager
maintainer = OpenVoHive <koudejun@live.com>
license = Apache-2.0
depends = libc luci-base curl
EOF

    local APK_NAME="${PKG}_${PKG_VERSION}-${PKG_RELEASE}_all.apk"
    cd "$PKG_DIR"
    tar czpf "$OUTPUT_DIR/$APK_NAME" --owner=0 --group=0 ./
    cd "$OUTPUT_DIR"
    rm -rf "$PKG_DIR"

    log "APK 已生成: $OUTPUT_DIR/$APK_NAME ($(du -h "$OUTPUT_DIR/$APK_NAME" | cut -f1))"
}

build_ipk
build_apk

echo ""
echo "产物列表:"
ls -la "$OUTPUT_DIR"
