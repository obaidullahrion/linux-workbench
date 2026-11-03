# Ubuntu System Optimization Guide

A comprehensive guide for optimizing Ubuntu system performance, including multimedia codecs, storage maintenance, memory management, and system monitoring.

---

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [Storage Optimization](#storage-optimization)
3. [Memory Management](#memory-management)
4. [GRUB Configuration](#grub-configuration)
5. [CPU Performance](#cpu-performance)
6. [System Logging](#system-logging)
7. [System Monitoring](#system-monitoring)
8. [Service Management](#service-management)

---

## Initial Setup

### Install Multimedia Codecs

Install essential multimedia codecs and restricted extras for better media compatibility:

```bash
sudo apt install ubuntu-restricted-extras
```

This package includes:
- Audio codecs (MP3, AAC, etc.)
- Video codecs
- Microsoft TrueType fonts
- Flash plugin support

---

## Storage Optimization

### Enable TRIM for SSD

TRIM helps maintain SSD performance and longevity by allowing the OS to inform the SSD which data blocks are no longer in use.

#### Manual TRIM Execution

```bash
sudo fstrim -v /
```

The `-v` flag provides verbose output showing the amount of data trimmed.

#### Check TRIM Timer Status

Ubuntu typically has a weekly TRIM timer enabled by default. Verify its status:

```bash
systemctl status fstrim.timer
```

Expected output should show the timer as `active` with next execution time.

---

## Memory Management

### Swappiness Configuration

Swappiness controls how aggressively the kernel swaps memory pages to disk. Lower values keep more data in RAM.

#### Check Current Swappiness

```bash
cat /proc/sys/vm/swappiness
```

Default value is usually `60`.

#### Set Swappiness Temporarily

```bash
sudo sysctl vm.swappiness=15
```

#### Make Swappiness Permanent

```bash
echo "vm.swappiness=15" | sudo tee -a /etc/sysctl.conf
```

**Recommended values:**
- Desktop: `10-15`
- Server: `10`
- Default: `60`

---

## GRUB Configuration

### Enable ZSWAP for Better Memory Compression

ZSWAP creates a compressed cache for swap pages in RAM, improving performance.

#### Edit GRUB Configuration

```bash
sudo nano /etc/default/grub
```

#### Modify GRUB Command Line

Update the following line:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=20"
```

**Parameters explained:**
- `zswap.enabled=1` - Enables ZSWAP
- `zswap.compressor=lz4` - Uses LZ4 compression (fast)
- `zswap.max_pool_percent=20` - Limits ZSWAP pool to 20% of RAM

#### Update GRUB

```bash
sudo update-grub
```

Reboot to apply changes.

---

## CPU Performance

### Install CPU Frequency Utilities

```bash
sudo apt install cpufrequtils
```

### Run CPU Boost Script

Execute the CPU boost script from the mintscript folder:

```bash
sudo ./mintscript/cpuboost.sh
```

This script optimizes CPU governor settings for better performance.

---

## System Logging

### Limit Journal Log Size

Reduce systemd journal log size to save disk space and improve performance.

#### Edit Journal Configuration

```bash
sudo nano /etc/systemd/journald.conf
```

#### Add Size Limits

Uncomment and set the following values:

```ini
SystemMaxUse=50M
RuntimeMaxUse=50M
```

**Parameters explained:**
- `SystemMaxUse` - Maximum disk space for persistent logs
- `RuntimeMaxUse` - Maximum memory for runtime logs

#### Restart Journald

```bash
sudo systemctl restart systemd-journald
```

---

## System Monitoring

### Analyze Startup Time

Identify services that slow down boot time:

```bash
systemd-analyze blame
```

This displays services sorted by initialization time.

#### Additional Analysis Commands

```bash
# Overall boot time
systemd-analyze

# Critical chain
systemd-analyze critical-chain

# Generate SVG plot
systemd-analyze plot > boot-analysis.svg
```

---

## Service Management

### List All Enabled Services

View all services that start automatically at boot:

```bash
systemctl list-unit-files --type=service --no-pager --no-legend | awk '$2=="enabled" {print $1}'
```

#### Disable Unnecessary Services

```bash
sudo systemctl disable <service-name>
```

#### Common Services to Consider Disabling

- `bluetooth.service` (if not using Bluetooth)
- `cups.service` (if not printing)
- `ModemManager.service` (if no mobile broadband)

**Note:** Only disable services you understand and don't need.

---

## Verification and Testing

### Verify ZSWAP Status

```bash
cat /sys/module/zswap/parameters/enabled
```

Should return `Y`.

### Check ZSWAP Statistics

```bash
grep -r . /sys/kernel/debug/zswap/
```

### Verify Swappiness

```bash
cat /proc/sys/vm/swappiness
```

Should return `15`.

### Check Journal Size

```bash
journalctl --disk-usage
```

---

## Troubleshooting

### GRUB Not Updating

If GRUB changes don't apply:

```bash
sudo update-grub
sudo reboot
```

### Services Won't Disable

```bash
sudo systemctl mask <service-name>
```

### TRIM Not Working

Check if your SSD supports TRIM:

```bash
sudo hdparm -I /dev/sda | grep TRIM
```

---

## Additional Resources

- [Ubuntu Documentation](https://help.ubuntu.com/)
- [systemd Documentation](https://www.freedesktop.org/software/systemd/man/)
- [ZSWAP Kernel Documentation](https://www.kernel.org/doc/html/latest/vm/zswap.html)

---

## License

This guide is provided as-is for educational and optimization purposes.

## Contributing

Feel free to suggest improvements or report issues with these optimization techniques.

---

**Last Updated:** January 2026  
**Compatible with:** Ubuntu 20.04, 22.04, 24.04 and derivatives
