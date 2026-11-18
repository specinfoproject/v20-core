#!/usr/bin/env bash
# SpecInfo Field-Triage Script — NVMe & GPU PCIe Link Width/Speed Audit (Read-Only)
# Flags silent PCIe x4 -> x2/x1 or Gen4 -> Gen3/Gen1 downgrades using Linux sysfs.
# Companion Guide: https://specinfo.org/blog/m2-nvme-pcie-lane-downgrade.html

set -euo pipefail

echo "=== SpecInfo PCIe Link Width & Speed Audit (Read-Only) ==="
printf "%-14s %-11s %-12s %-12s %-10s %s\n" "BDF" "TYPE" "MAX_LINK" "CUR_LINK" "STATUS" "DEVICE"
printf "%-14s %-11s %-12s %-12s %-10s %s\n" "--------------" "-----------" "------------" "------------" "----------" "------------------------------"

found=0
for dev in /sys/bus/pci/devices/*; do
    [ -r "$dev/class" ] || continue
    [ -r "$dev/current_link_width" ] || continue
    [ -r "$dev/max_link_width" ] || continue

    cls=$(<"$dev/class")
    kind=""
    case "$cls" in
        0x0108*) kind="NVMe" ;;
        0x0300*|0x0302*) kind="GPU" ;;
        0x0107*|0x0100*) kind="HBA/SAS" ;;
        0x0200*) kind="NIC" ;;
        *) continue ;;
    esac

    bdf="${dev##*/}"
    cur_w=$(tr -d '[:space:]' < "$dev/current_link_width" 2>/dev/null || echo "?")
    max_w=$(tr -d '[:space:]' < "$dev/max_link_width" 2>/dev/null || echo "?")
    cur_s=$(tr -d '[:space:]' < "$dev/current_link_speed" 2>/dev/null || echo "?")
    max_s=$(tr -d '[:space:]' < "$dev/max_link_speed" 2>/dev/null || echo "?")

    # Normalize speed label (first token, e.g. "16.0" from "16.0 GT/s PCIe")
    cur_gt="${cur_s%% *}"
    max_gt="${max_s%% *}"

    status="OK"
    if [[ "$cur_w" =~ ^[0-9]+$ ]] && [[ "$max_w" =~ ^[0-9]+$ ]] && [ "$cur_w" -lt "$max_w" ]; then
        status="WARN_WIDTH"
    elif [ "$cur_s" != "$max_s" ] && [ "$cur_s" != "Unknown" ]; then
        status="IDLE/PWR"
    fi

    name="$bdf"
    if command -v lspci >/dev/null 2>&1; then
        name=$(lspci -s "$bdf" 2>/dev/null | sed 's/^[^ ]* //' || echo "$bdf")
    fi

    printf "%-14s %-11s x%-2s@%-6s  x%-2s@%-6s  %-10s %s\n" \
        "$bdf" "$kind" "$max_w" "${max_gt}GT" "$cur_w" "${cur_gt}GT" "$status" "$name"
    found=$((found + 1))
done

if [ "$found" -eq 0 ]; then
    echo "No NVMe/GPU/HBA/NIC PCIe link entries exposed under /sys/bus/pci/devices."
fi

echo ""
echo "Note: WARN_WIDTH means fewer physical lanes than maximum (check M.2 bifurcation, dirty contacts, or OCuLink cables)."
echo "      IDLE/PWR on GPUs/NVMe at idle often recovers to full GT/s under I/O or compute load."
