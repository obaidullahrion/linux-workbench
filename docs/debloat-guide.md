# Ubuntu Debloat & Optimization Guide

This repository includes a written optimization guide in two forms:

| File | What it is |
| --- | --- |
| [`Linux-debloat-optimization-guide-main/README.md`](../Linux-debloat-optimization-guide-main/README.md) | The full, formatted guide |
| [`Linux-debloat-optimization-guide-main/debloadlinux.txt`](../Linux-debloat-optimization-guide-main/debloadlinux.txt) | Raw command notes (short, unpolished) |

This page is an annotated summary of both, with corrections and safety notes.

> **Read before you run anything.** These changes affect kernel parameters, swap behaviour, system services and logging. Make a backup of each file you edit, and make sure you can boot a recovery environment.

## 1. Multimedia codecs

```bash
sudo apt install ubuntu-restricted-extras
```

Installs common audio/video codecs, Microsoft TrueType fonts and related extras. Accept the licence prompt for the fonts when asked.

## 2. SSD TRIM

TRIM tells an SSD which blocks are free, maintaining performance and longevity.

```bash
# Run TRIM manually (verbose)
sudo fstrim -v /

# Check that the weekly timer is active
systemctl status fstrim.timer
```

Ubuntu enables a weekly `fstrim.timer` by default; you usually do **not** need to run `fstrim` manually.

Verify SSD TRIM support (optional, requires `hdparm`):

```bash
sudo hdparm -I /dev/sda | grep -i trim
```

> Replace `/dev/sda` with your actual device (`lsblk`). NVMe devices support TRIM automatically.

## 3. Swappiness

Swappiness controls how eagerly the kernel moves memory pages to swap.

```bash
# Current value (default is usually 60)
cat /proc/sys/vm/swappiness

# Temporary change
sudo sysctl vm.swappiness=15

# Permanent change
echo "vm.swappiness=15" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

Recommended values from the guide:

| Use case | Value |
| --- | --- |
| Desktop | `10`–`15` |
| Server | `10` |
| Distro default | `60` |

> A very low value is **not** automatically better. Systems with little RAM may need some swapping; test and monitor with `free -h` and `vmstat`.

## 4. ZSWAP (compressed swap cache)

ZSWAP keeps compressed swap pages in RAM, reducing disk I/O.

Edit `/etc/default/grub`:

```bash
sudo cp /etc/default/grub /etc/default/grub.backup
sudo nano /etc/default/grub
```

Update `GRUB_CMDLINE_LINUX_DEFAULT`, for example:

```ini
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=20"
```

| Parameter | Meaning |
| --- | --- |
| `zswap.enabled=1` | Enable ZSWAP |
| `zswap.compressor=lz4` | Use fast LZ4 compression |
| `zswap.max_pool_percent=20` | Cap the ZSWAP pool at 20% of RAM |

Apply:

```bash
sudo update-grub
sudo reboot
```

Verify after reboot:

```bash
cat /sys/module/zswap/parameters/enabled          # should print Y
grep -r . /sys/kernel/debug/zswap/ 2>/dev/null    # statistics (may need root)
```

> **Correction:** the raw notes (`debloadlinux.txt`) contain `GRUB_CMDLINE_LINUX_DEFAULT="profile zswap.enabled=1 …"`. `profile` is not a valid ZSWAP option — use the `quiet splash` line shown above.

## 5. CPU performance

```bash
sudo apt install cpufrequtils
```

The guide refers to `mintscript/cpuboost.sh`; in this repository the script is:

```bash
sudo bash "quick scripts /cpuboost.sh"
```

See [`docs/quick-scripts.md`](quick-scripts.md#cpuboostsh) for details. Available governors and persistence depend on your CPU driver.

## 6. Journal (systemd log) limits

Edit the journal configuration:

```bash
sudo nano /etc/systemd/journald.conf
```

Set:

```ini
SystemMaxUse=50M
RuntimeMaxUse=50M
```

| Setting | Meaning |
| --- | --- |
| `SystemMaxUse` | Maximum disk space for persistent logs |
| `RuntimeMaxUse` | Maximum memory for runtime (volatile) logs |

Restart journald:

```bash
sudo systemctl restart systemd-journald
journalctl --disk-usage
```

> 50 MB is small. It is fine for a light desktop, but you will lose older logs — raise it if you need history for debugging.

## 7. Analyze boot time

```bash
systemd-analyze                 # total boot time
systemd-analyze blame           # slowest services
systemd-analyze critical-chain  # dependency chain on the critical path
systemd-analyze plot > boot-analysis.svg   # visual timeline
```

Open the SVG in any browser. Use `blame` to find services worth disabling — not to disable things blindly.

## 8. Service management

List enabled services:

```bash
systemctl list-unit-files --type=service --no-pager --no-legend | awk '$2=="enabled" {print $1}'
```

Disable one:

```bash
sudo systemctl disable <service-name>
# Stronger: prevent it from being pulled in as a dependency
sudo systemctl mask <service-name>
```

The guide suggests these as candidates **if you don't use the feature**:

| Service | Disable only if… |
| --- | --- |
| `bluetooth.service` | You never use Bluetooth |
| `cups.service` | You never print |
| `ModemManager.service` | You have no mobile broadband modem |

> **Warning:** never disable a service you don't understand. Some look unimportant but are required for networking, audio, login or updates. Create a snapshot/backup first, and re-enable with `sudo systemctl enable <service>` if something breaks.

## Verification checklist

```bash
cat /proc/sys/vm/swappiness                 # expect 15
cat /sys/module/zswap/parameters/enabled    # expect Y
systemctl status fstrim.timer               # expect active
journalctl --disk-usage                     # expect ~50M or less
systemd-analyze                             # boot time overview
```

## Troubleshooting

| Problem | Fix |
| --- | --- |
| GRUB changes ignored | Run `sudo update-grub` and reboot; check the line is in `GRUB_CMDLINE_LINUX_DEFAULT` |
| ZSWAP not enabled | Confirm the kernel parameter, check `dmesg | grep -i zswap`, and that your kernel has ZSWAP built in |
| Service won't stay disabled | Use `sudo systemctl mask <service>` |
| Need to undo a service change | `sudo systemctl unmask <service> && sudo systemctl enable <service>` |
| TRIM not working | Check the device (`lsblk`), the filesystem, and `systemctl status fstrim.timer` |
| System unstable after tuning | Restore `/etc/default/grub.backup`, `sudo update-grub`, reboot; revert `/etc/sysctl.conf` edits |

## References

- [Ubuntu Documentation](https://help.ubuntu.com/)
- [systemd Documentation](https://www.freedesktop.org/software/systemd/man/)
- [ZSWAP Kernel Documentation](https://www.kernel.org/doc/html/latest/vm/zswap.html)
- [Arch Wiki — Improving performance](https://wiki.archlinux.org/title/Improving_performance)
