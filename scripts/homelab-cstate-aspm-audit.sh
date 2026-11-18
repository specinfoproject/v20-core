#!/usr/bin/env bash
# SpecInfo Homelab Power Audit — CPU Governors, C-States & PCIe ASPM Check (Read-Only)
# Helps identify drivers or ASPM policy locks keeping 24/7 servers out of Package C8/C10.
# Companion Guide: https://specinfo.org/blog/low-power-homelab-server-under-15w-n100-n305-c-states-guide.html

set -euo pipefail

echo "=== SpecInfo Homelab C-States & PCIe ASPM Audit (Read-Only) ==="

echo ""
echo "--- CPU Scaling Governor & Energy Preference ---"
if [ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
    echo "Governor (cpu0): $(< /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
fi
if [ -r /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference ]; then
    echo "EPP (cpu0):      $(< /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)"
fi

echo ""
echo "--- Active cpuidle Driver & States (cpu0) ---"
if [ -r /sys/devices/system/cpu/cpuidle/current_driver ]; then
    echo "cpuidle driver: $(< /sys/devices/system/cpu/cpuidle/current_driver)"
fi
for st in /sys/devices/system/cpu/cpu0/cpuidle/state*; do
    [ -d "$st" ] || continue
    nm=$(< "$st/name")
    dis=$(< "$st/disable")
    usg=$(< "$st/usage")
    echo "  $(basename "$st"): name=$nm disabled=$dis usage=$usg"
done

echo ""
echo "--- PCIe Active State Power Management (ASPM) Policy ---"
if [ -r /sys/module/pcie_aspm/parameters/policy ]; then
    echo "Kernel ASPM policy: $(< /sys/module/pcie_aspm/parameters/policy)"
else
    echo "pcie_aspm sysfs policy not exposed."
fi

echo ""
echo "--- PCIe Devices With ASPM Disabled (Requires root lspci for full LnkCtl decode) ---"
if command -v lspci >/dev/null 2>&1; then
    if [ "$(id -u)" -eq 0 ]; then
        lspci -vv 2>/dev/null | awk '
            /^[^ \t]/ { dev=$0; aspm="" }
            /LnkCtl:.*ASPM Disabled/ { print "  [ASPM OFF] " dev }
        ' | head -n 25 || true
    else
        echo "  Skipped detailed lspci LnkCtl scan (run with sudo lspci -vv to inspect ASPM Disabled endpoints)."
    fi
else
    echo "  lspci not installed."
fi
