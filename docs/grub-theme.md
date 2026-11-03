# GRUB Theme — `BlackSwan`

A GRUB 2 boot-menu theme packaged as [`grub theme/BlackSwan.zip`](../grub%20theme/BlackSwan.zip).

The archive contains a full theme:

```text
BlackSwan/
├── background.png     # full-screen background
├── theme.txt          # theme layout/colours
├── select_*.png       # selection pixmaps (N, S, E, W, corners, centre)
└── icons/             # per-distribution boot icons (Arch, Ubuntu, Fedora, Windows, …)
```

## Theme layout (`theme.txt`)

| Setting | Value |
| --- | --- |
| Background | `background.png` |
| Boot menu position | left `100`, top `47%` |
| Boot menu size | `472` × `35%` |
| Item height | `40`, spacing `40` |
| Icon size | `36` × `36` |
| Selected item style | `select_*.png` pixmaps |
| Timeout label | bottom-left, “Selected OS will start in %d seconds” |

## Requirements

- GRUB 2 (standard on Ubuntu/Debian/Fedora/Arch).
- The theme is designed for a **1920×1080**-class background; other resolutions are scaled by GRUB.

Check your GRUB version:

```bash
grub-install --version
```

## Install

### 1. Back up your GRUB config

```bash
sudo cp /etc/default/grub /etc/default/grub.backup
```

### 2. Extract the theme

```bash
# Ubuntu/Debian theme directory
sudo mkdir -p /boot/grub/themes
sudo unzip "grub theme/BlackSwan.zip" -d /tmp/blackswan
sudo cp -r /tmp/blackswan/BlackSwan /boot/grub/themes/BlackSwan
```

> Some distributions use `/usr/share/grub/themes/` instead. Either location works as long as `GRUB_THEME` points to the `.txt` file.

### 3. Point GRUB at the theme

Edit `/etc/default/grub`:

```bash
sudo nano /etc/default/grub
```

Add (or update) these lines:

```ini
GRUB_THEME="/boot/grub/themes/BlackSwan/theme.txt"
GRUB_GFXMODE=1920x1080
GRUB_GFXPAYLOAD_LINUX=keep
```

- `GRUB_THEME` — absolute path to the theme's `theme.txt`.
- `GRUB_GFXMODE` — menu resolution; use `auto` if unsure.
- `GRUB_GFXPAYLOAD_LINUX=keep` — keeps the same resolution when handing off to Linux (optional, but keeps the boot sequence looking consistent).

### 4. Regenerate the GRUB configuration

```bash
sudo update-grub          # Ubuntu/Debian
# or: sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 5. Reboot

```bash
sudo reboot
```

## Test without rebooting

If your distro provides `grub-emu`:

```bash
sudo grub-emu --theme=/boot/grub/themes/BlackSwan/theme.txt
```

(Not available everywhere, and it needs a graphical terminal.)

## Uninstall

```bash
sudo cp /etc/default/grub.backup /etc/default/grub   # if you made one
# or delete/comment the GRUB_THEME line
sudo update-grub
sudo rm -rf /boot/grub/themes/BlackSwan
```

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Menu looks unchanged | Confirm the `GRUB_THEME` path is correct and run `sudo update-grub` |
| “file not found” at boot | The theme must be readable by GRUB; keep it inside `/boot` (or the GRUB prefix) |
| Low-resolution menu | Set `GRUB_GFXMODE` to a mode reported by `videoinfo` in the GRUB command line |
| Icons missing | Distro icon names must match `icons/<name>.png`; add your own icon file |
| System won't boot | Boot a live USB, mount your root partition, and restore `/etc/default/grub`, then re-run `update-grub` from a chroot |

See also [Troubleshooting](troubleshooting.md).

## Notes

- The original one-line instructions shipped in [`grub theme/Readme.md`](../grub%20theme/Readme.md) are preserved; this document supersedes them with a complete procedure.
- GRUB themes are cosmetic only — they do not affect boot entries. Still, **always** keep a recovery method available when editing boot configuration.
