#!/usr/bin/env bash
# SpecInfo SRE Triage Script — Disk Full, Inode Exhaustion & Ghost Space Check (Read-Only)
# Detects deleted files still held open by running PIDs (/proc/*/fd) & /tmp tmpfs pressure.
# Companion Guide: https://specinfo.org/blog/linux-3am-disk-full-ghost-space-inodes-strace-vs-ebpf-proxmox-lab-guide.html

set -euo pipefail

echo "=== 1. Filesystem Block Usage (df -h) ==="
df -h -x tmpfs -x devtmpfs -x squashfs 2>/dev/null || df -h

echo ""
echo "=== 2. Filesystem Inode Usage (df -i) ==="
df -i -x tmpfs -x devtmpfs -x squashfs 2>/dev/null || df -i

echo ""
echo "=== 3. RAM-Backed /tmp (tmpfs) Check ==="
if mountpoint -q /tmp 2>/dev/null; then
    df -hT /tmp
else
    echo "/tmp is not a separate mountpoint."
fi

echo ""
echo "=== 4. Top Deleted-But-Open File Descriptors (Ghost Space via /proc/*/fd) ==="
if [ "$(id -u)" -ne 0 ]; then
    echo "(Running without root: only current user processes can be inspected; run with sudo for host-wide scan.)"
fi

awk_found=0
while IFS= read -r line; do
    echo "$line"
    awk_found=1
done < <(
    find /proc/[0-9]*/fd -lname '*(deleted)*' 2>/dev/null \
    | while IFS= read -r fdpath; do
        target=$(readlink "$fdpath" 2>/dev/null || true)
        [ -n "$target" ] || continue
        pid=$(printf '%s' "$fdpath" | cut -d/ -f3)
        comm=$(tr -d '\0\n' < "/proc/$pid/comm" 2>/dev/null || echo "unknown")
        sz=$(stat -L -c '%s' "$fdpath" 2>/dev/null || echo "0")
        printf "%12s  PID=%-7s  %-18s  %s -> %s\n" "$sz" "$pid" "$comm" "$fdpath" "$target"
    done | sort -rn | head -n 15
)

if [ "$awk_found" -eq 0 ]; then
    echo "No visible deleted-but-open file descriptors found."
fi

echo ""
echo "Safe tip: For active Ghost Space logs, avoid 'rm' alone—truncate the open fd or reload the service."
