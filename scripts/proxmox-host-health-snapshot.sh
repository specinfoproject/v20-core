#!/usr/bin/env bash
# SpecInfo Homelab Snapshot — Read-Only Proxmox VE / Linux Host Health Summary
# Captures kernel, hypervisor version, storage pools, guests, and SMART disk health without modifying anything.
# Companion Guide: https://specinfo.org/blog/best-mini-pcs-for-local-ai-homelab-proxmox-hierarchy.html

set -euo pipefail

echo "=== SpecInfo Host & Storage Health Snapshot (Read-Only) ==="
echo "Hostname: $(hostname 2>/dev/null || echo unknown)"
echo "Kernel:   $(uname -srm)"
echo "Uptime:   $(uptime -p 2>/dev/null || uptime)"

if command -v pveversion >/dev/null 2>&1; then
    echo ""
    echo "--- Proxmox VE Version ---"
    pveversion 2>/dev/null || true
fi

if command -v pvesm >/dev/null 2>&1; then
    echo ""
    echo "--- Proxmox Storage Status ---"
    pvesm status 2>/dev/null || true
fi

if command -v pct >/dev/null 2>&1; then
    echo ""
    echo "--- LXC Containers (pct list) ---"
    pct list 2>/dev/null || true
fi

if command -v qm >/dev/null 2>&1; then
    echo ""
    echo "--- QEMU/KVM VMs (qm list) ---"
    qm list 2>/dev/null || true
fi

if command -v zpool >/dev/null 2>&1; then
    echo ""
    echo "--- ZFS Pools ---"
    zpool status -x 2>/dev/null || true
fi

echo ""
echo "--- Block Devices (lsblk) ---"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL 2>/dev/null || true

if command -v smartctl >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
    echo ""
    echo "--- SMART Overall Health ---"
    for d in /dev/nvme[0-9]n[0-9] /dev/sd[a-z]; do
        [ -b "$d" ] || continue
        hlth=$(smartctl -H "$d" 2>/dev/null | grep -iE 'overall-health|SMART Health Status' | head -n 1 || true)
        echo "  $d: ${hlth:-unavailable}"
    done
fi
