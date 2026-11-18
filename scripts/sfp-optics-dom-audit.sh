#!/usr/bin/env bash
# SpecInfo Network Diagnostics — NIC Driver & SFP+ DOM Optical Telemetry Check (Read-Only)
# Lists interfaces, driver modules, link speeds, and SFP+ EEPROM / DDM values via ethtool.
# Companion Guide: https://specinfo.org/blog/sfp-plus-vendor-lock-oem-vs-unlocked-compatible-optics-eeprom-guide.html

set -euo pipefail

echo "=== SpecInfo NIC Driver & SFP+ DOM Audit (Read-Only) ==="

if ! command -v ip >/dev/null 2>&1; then
    echo "ip command not found."
    exit 0
fi

has_ethtool=0
if command -v ethtool >/dev/null 2>&1; then
    has_ethtool=1
fi

for ifpath in /sys/class/net/*; do
    iface="${ifpath##*/}"
    case "$iface" in
        lo|veth*|fwbr*|fwpr*|fwln*|tap*|docker*|br-*|tailscale*) continue ;;
    esac

    state=$(tr -d '[:space:]' < "$ifpath/operstate" 2>/dev/null || echo "unknown")
    speed=$(tr -d '[:space:]' < "$ifpath/speed" 2>/dev/null || echo "N/A")
    drv="unknown"
    if [ -L "$ifpath/device/driver" ]; then
        drv=$(basename "$(readlink -f "$ifpath/device/driver")")
    fi

    echo ""
    echo ">>> Interface: $iface | state=$state | speed=${speed}Mbps | driver=$drv"
    if [ "$has_ethtool" -eq 1 ]; then
        ethtool -i "$iface" 2>/dev/null | grep -E '^(driver|version|firmware-version):' || true
        dom=$(ethtool -m "$iface" 2>/dev/null || true)
        if [ -n "$dom" ]; then
            echo "    [SFP/SFP+ DOM Telemetry]"
            printf '%s\n' "$dom" | grep -iE 'Vendor name|Vendor PN|Vendor OUI|Identifier|Connector|Laser output power|Receiver signal|Module temperature|Laser bias' | sed 's/^/    /' || true
        fi
    fi
done

if [ "$has_ethtool" -eq 0 ]; then
    echo ""
    echo "Install ethtool (apt install ethtool) to inspect SFP+ EEPROM & DOM optical power readings."
fi
