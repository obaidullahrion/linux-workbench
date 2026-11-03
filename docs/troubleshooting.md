# Troubleshooting

Common issues across the workbench. Each section links to the relevant detailed document.

## General recovery

Before changing boot-related things:

```bash
# Back up the files you are about to edit
sudo cp /etc/default/grub /etc/default/grub.backup
sudo cp /etc/systemd/journald.conf /etc/systemd/journald.conf.backup
```

If the system no longer boots:

1. Boot a live USB.
2. Mount your root partition and `chroot` into it (or use `boot-repair`).
3. Restore the backup file and regenerate the boot config:

   ```bash
   sudo update-grub
   sudo update-initramfs -u
   ```

## Boot / Plymouth

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Black screen at boot | Bad theme or graphics driver | Add `plymouth.enable=0` to the kernel command line temporarily; switch to the `text` theme |
| Theme not applied | Alternative not selected / initramfs not rebuilt | `sudo update-alternatives --config default.plymouth`, then `sudo update-initramfs -u` |
| Animation too fast/slow | Frame divisor in the script | Edit `Math.Int(progress / 2)` in `cuts_alt.script` |
| No password prompt | No boot password/encryption configured | Expected behaviour |

→ [Boot Animation](boot-animation.md)

## GRUB

| Symptom | Fix |
| --- | --- |
| Theme not visible | Check the `GRUB_THEME` path and run `sudo update-grub` |
| “file not found” | Move the theme under `/boot/grub/themes/` |
| Low-resolution menu | Set `GRUB_GFXMODE` (try `auto`, then a mode from `videoinfo`) |
| No GRUB menu at all | Hold <kbd>Shift</kbd> (BIOS) or press <kbd>Esc</kbd> (UEFI) during boot |

→ [GRUB Theme](grub-theme.md)

## Cursors

| Symptom | Fix |
| --- | --- |
| Cursor unchanged | The theme name must match the folder name: `Future-cyan-cursors` |
| Only some apps change | Log out/in, or install to `/usr/share/icons` |
| Flatpak/Snap ignores it | Install system-wide and restart the app |
| Wayland app ignores it | Export `XCURSOR_THEME` before the compositor starts |
| Too large/small | Set `cursor-size` / `XCURSOR_SIZE` (e.g. `24`) |

→ [Cursor Theme](cursor-theme.md)

## Keybindings

| Symptom | Fix |
| --- | --- |
| `xmodmap` has no effect | You are on Wayland; `xmodmap` is X11-only |
| Mapping lost after reboot | Re-run the script or add it to autostart |
| Wrong key changes | Keycodes are hardware-specific; re-check with `xev` |
| A mapping is ignored | A later line overrides the same keycode (see the `105` note) |

→ [Keybindings](keybindings.md)

## Quick scripts

### `cpuboost.sh`

| Symptom | Fix |
| --- | --- |
| `cpufreq-info: command not found` | `sudo apt install cpufrequtils` |
| Governor won't change | Your driver may not support it; check `cpufreq-info` |
| Only some cores change | The script is hard-coded to cores `0 1 2 3`; edit the loops |
| Setting lost on reboot | Persist via `/etc/default/cpufrequtils` or a systemd unit |

### `webcam.sh`

| Symptom | Fix |
| --- | --- |
| Black window | Another app is using the camera, or `/dev/video0` is wrong |
| Upside-down image | Remove `--vf=hflip` or use `--vf=vflip` |
| `mpv: command not found` | `sudo apt install mpv` |

### `startandroid.sh` / `stopandroid.sh`

| Symptom | Fix |
| --- | --- |
| Weston fails to start | You are on pure Wayland; change `--backend=x11-backend.so` |
| Waydroid window is blank | Wait for the container to boot; check `sudo systemctl status waydroid-container` |
| Network doesn't work in Android | Re-check the UFW rules (`sudo ufw status verbose`) |
| Firewall left open | Run `stopandroid.sh`; verify with `sudo ufw status` |

### `audiorelay-start.sh` / `audiorelay-stop.sh`

| Symptom | Fix |
| --- | --- |
| `pactl: command not found` | `sudo apt install pulseaudio-utils` |
| No “Virtual-Mic” in apps | Run `pactl list short sources` and check the module loaded |
| Duplicate sinks | Run the stop script, then start again |
| No audio sent | Route playback into “Virtual-Mic-Sink” with `pavucontrol` |

### `colorpicker.sh`

| Symptom | Fix |
| --- | --- |
| `gpick` missing | `sudo apt install gpick` |
| Closes too late/early | Change `sleep 60` in the script |
| Nothing copied | Left-click the pixel; the colour is copied to the clipboard |

### `onekoreset.sh`

| Symptom | Fix |
| --- | --- |
| Cat comes back | Disable the `oneko` autostart entry |
| Cursor doesn't reset | The DE overrides the root cursor; change the cursor theme instead |
| `xsetroot: command not found` | `sudo apt install x11-xserver-utils` |

→ [Quick Scripts](quick-scripts.md)

## Debloat guide

| Symptom | Fix |
| --- | --- |
| ZSWAP not active | Verify the kernel line, reboot, check `dmesg | grep -i zswap` |
| Service won't stay disabled | `sudo systemctl mask <service>` |
| Need to undo a service change | `sudo systemctl unmask <service> && sudo systemctl enable <service>` |
| System unstable after tuning | Restore backups and reboot |

→ [Debloat Guide](debloat-guide.md)

## Still stuck?

- Read the script you're running; it is short and commented.
- Check the logs: `journalctl -xe`, `dmesg`, `~/.xsession-errors`.
- Verify the tool is installed: `command -v <tool>`.
- When opening an issue, include your distribution/version, desktop session (X11 or Wayland), and the exact command and error.
