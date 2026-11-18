# 🛠️ SpecInfo V20 Core — Open Field-Triage CLI Scripts

![Read-Only](https://img.shields.io/badge/CLI-100%25%20Read--Only-22c55e) ![Zero-Knowledge](https://img.shields.io/badge/Architecture-Zero--Knowledge-0ea5e9) ![License](https://img.shields.io/badge/License-MIT-334155) ![Origin](https://img.shields.io/badge/Origin-England%20%26%20Wales%20Lab-475569)

Open-source companion repository for **[SpecInfo Engineering Lab (UK)](https://specinfo.org/)** ([GitHub Profile](https://github.com/specinfoproject)). Contains lightweight, **100% read-only** Bash field-triage utilities for Linux workstations, homelabs, optical networking, and Proxmox VE nodes.

> 🔒 **Zero-Knowledge & Read-Only:** Every script under [`scripts/`](./scripts/) inspects local sysfs, procfs, `lspci`, `ethtool`, and `smartctl` / `pve` state locally without modifying configuration files or transmitting telemetry to external servers.

---

## 📂 Included Field-Triage Scripts (`scripts/`)

| Script | Purpose | Companion Engineering Guide |
| :--- | :--- | :--- |
| [`scripts/nvme-pcie-lane-audit.sh`](./scripts/nvme-pcie-lane-audit.sh) | Detects silent PCIe `x4 -> x2/x1` speed/width downgrades on NVMe SSDs and GPUs via sysfs & `lspci` | [M.2 NVMe PCIe Lane Downgrade Guide](https://specinfo.org/blog/m2-nvme-pcie-lane-downgrade.html) |
| [`scripts/linux-ghost-space-inodes-check.sh`](./scripts/linux-ghost-space-inodes-check.sh) | Audits `df -h` vs `df -i` inode exhaustion, `/tmp` `tmpfs` usage, and deleted-but-open `/proc/*/fd` Ghost Space | [3 AM Linux Disk & eBPF Rescue Lab](https://specinfo.org/blog/linux-3am-disk-full-ghost-space-inodes-strace-vs-ebpf-proxmox-lab-guide.html) |
| [`scripts/homelab-cstate-aspm-audit.sh`](./scripts/homelab-cstate-aspm-audit.sh) | Inspects CPU scaling governors, active `cpuidle` states, and PCIe ASPM L1 blockers preventing sub-15W idle | [Low-Power <15W Homelab & C-States](https://specinfo.org/blog/low-power-homelab-server-under-15w-n100-n305-c-states-guide.html) |
| [`scripts/sfp-optics-dom-audit.sh`](./scripts/sfp-optics-dom-audit.sh) | Enumerates NIC drivers and reads optical transceiver EEPROM / DOM telemetry (`ethtool -m`) | [SFP+ Vendor-Lock & DOM Diagnostics](https://specinfo.org/blog/sfp-plus-vendor-lock-oem-vs-unlocked-compatible-optics-eeprom-guide.html) |
| [`scripts/proxmox-host-health-snapshot.sh`](./scripts/proxmox-host-health-snapshot.sh) | Collects read-only Proxmox VE / Linux host storage, pool (`ZFS`/`Btrfs`), LXC/VM & SMART status | [Best Mini PCs for Proxmox & Local AI](https://specinfo.org/blog/best-mini-pcs-for-local-ai-homelab-proxmox-hierarchy.html) |

### Quick Usage (Always Inspect Before Running)

```bash
git clone https://github.com/specinfoproject/v20-core.git
cd v20-core/scripts
chmod +x *.sh

# Check PCIe NVMe / GPU link widths
./nvme-pcie-lane-audit.sh

# Check Ghost Space, inode exhaustion, and /tmp tmpfs pressure (sudo shows all PIDs)
sudo ./linux-ghost-space-inodes-check.sh

# Check ASPM / C-State power blockers, SFP+ DOM telemetry, or Proxmox node health
./homelab-cstate-aspm-audit.sh
./sfp-optics-dom-audit.sh
./proxmox-host-health-snapshot.sh
```

---

## 🌐 SpecInfo Ecosystem & Related Guides

- 🏠 **Platform Showcase & All Modules:** [`github.com/specinfoproject`](https://github.com/specinfoproject) • [specinfo.org](https://specinfo.org/)
- 📚 **Engineering Guides (Rolling Release):** [specinfo.org/blog/](https://specinfo.org/blog/) ([PL](https://specinfo.org/pl/blog/)) • [RSS `rss.xml`](https://specinfo.org/rss.xml)
- 🐧 **Runbooks & Crash Doctor:** [specinfo.org/runbook/](https://specinfo.org/runbook/) • [specinfo.org/crash-doctor/](https://specinfo.org/crash-doctor/)
- 💾 **Enterprise ITAD & SAS Wipe Guides:** [SAS `520B` `sg_format` & Pin 3 `PWDIS`](https://specinfo.org/blog/sas-drive-not-detected-520-byte-sector-format-hba-pwdis-itad-guide.html) • [Aiken HBA/JBOD Wiping Station](https://specinfo.org/blog/sas-drive-wiping-station-aiken-hba-jbod-itad-build-guide.html)

---

## 🔗 Official Channels & Verification

- 📺 **YouTube Channel:** [@SpecInfoOrg](https://www.youtube.com/@SpecInfoOrg)
- 📘 **Facebook Page:** [SpecInfo Official](https://www.facebook.com/profile.php?id=61595280802689)
- 📋 **Engineering Credentials & Legal Notice:** [specinfo.org/legal/about.html](https://specinfo.org/legal/about.html)
- 🤖 **LLM Knowledge Index:** [specinfo.org/llms.txt](https://specinfo.org/llms.txt)

---

*Maintained by **SpecInfo Engineering Lab** (Krzysztof Damek t/a SpecInfo, registered in England & Wales).*
