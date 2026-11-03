# Boot Animation (Plymouth) — `cuts_alt`

A **Plymouth** boot splash theme that replaces the default Ubuntu/Debian boot logo with a 41-frame animation, plus themed password, question and message prompts.

- **Theme name:** `cuts_alt`
- **Author:** Aditya Shakya ([@adi1090x](https://github.com/adi1090x))
- **License:** GNU GPL v3 — see [`../boot animation/cuts_alt/LICENSE`](../boot%20animation/cuts_alt/LICENSE)
- **Type:** Plymouth `script` module theme

## Files

| File | Purpose |
| --- | --- |
| `cuts_alt.plymouth` | Theme descriptor read by Plymouth |
| `cuts_alt.script` | Animation and prompt logic |
| `progress-0.png` … `progress-40.png` | 41 animation frames |
| `LICENSE` | GPLv3 license text |

## How the theme works

`cuts_alt.plymouth` tells Plymouth where the theme lives:

```ini
[Plymouth Theme]
Name=cuts_alt
Description=display ninja style cuts
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/cuts_alt
ScriptFile=/usr/share/plymouth/themes/cuts_alt/cuts_alt.script
```

`cuts_alt.script`:

1. Loads all 41 frames (`progress-0.png` … `progress-40.png`).
2. Centres a sprite on screen and advances it on every refresh:

   ```text
   flyingman_sprite.SetImage(flyingman_image[Math.Int(progress / 2) % 41]);
   progress++;
   ```

   Each frame is therefore shown for two refresh ticks, and the animation loops forever.
3. Draws password bullets, a “Enter Password” prompt, question/answer text and general messages near the bottom of the screen.
4. Pauses the animation while a password is being entered and resumes afterwards.

> The `.plymouth` file hard-codes `/usr/share/plymouth/themes/cuts_alt`, so install the folder under exactly that name.

## Requirements

```bash
sudo apt install plymouth plymouth-themes initramfs-tools
```

Verify Plymouth is installed and active:

```bash
plymouth --version
```

## Install

From the repository root:

```bash
# 1. Copy the theme into Plymouth's theme directory
sudo cp -r "boot animation/cuts_alt" /usr/share/plymouth/themes/cuts_alt

# 2. Register it as an alternative for default.plymouth
sudo update-alternatives --install \
  /usr/share/plymouth/themes/default.plymouth \
  default.plymouth \
  /usr/share/plymouth/themes/cuts_alt/cuts_alt.plymouth \
  100

# 3. Select it (choose the number next to cuts_alt)
sudo update-alternatives --config default.plymouth

# 4. Rebuild the initramfs so the theme is available early in boot
sudo update-initramfs -u
```

Reboot to see it:

```bash
sudo reboot
```

### Install with the `plymouth-set-default-theme` helper (some distros)

On distributions that ship the helper, this is shorter:

```bash
sudo plymouth-set-default-theme -R cuts_alt
```

The `-R` flag rebuilds the initramfs automatically.

## Test without rebooting

Plymouth normally only runs on a real console. You can preview it from a TTY (press `Ctrl+Alt+F3`, log in) or, on many systems, from a terminal:

```bash
sudo plymouthd
sudo plymouth --show-splash
sleep 5
sudo plymouth quit
```

If the preview stays black, that is often a graphics-driver limitation rather than a broken theme. Always keep a working TTY available before changing boot visuals.

## Customize

- **Speed:** in `cuts_alt.script`, change `Math.Int(progress / 2)` — a smaller divisor (e.g. `/ 1`) is faster, a larger one (e.g. `/ 3`) is slower.
- **Frame count:** the loop and modulo use `41`. If you add/remove frames, update **both** `i < 41` and `% 41`.
- **Frame size/position:** edit the `SetX`/`SetY` calls near the top of the script.
- **Prompt text:** search for `"Enter Password"` and `"Selected OS will start"`-style strings in the script.
- **Frames:** replace `progress-*.png` with your own images, keeping the same names and count.

After editing an installed theme, rebuild the initramfs:

```bash
sudo update-initramfs -u
```

## Uninstall / revert

Switch back to the distribution default:

```bash
# List available themes
sudo update-alternatives --config default.plymouth

# Or explicitly pick the distro default (examples)
sudo plymouth-set-default-theme -R bgrt     # Ubuntu (BIOS/logo)
sudo plymouth-set-default-theme -R text     # plain text fallback

# Then remove the files if you want
sudo rm -rf /usr/share/plymouth/themes/cuts_alt
sudo update-initramfs -u
```

If `bgrt` is not available, use `text` — it always works and is a safe fallback.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Black screen at boot | Boot with `plymouth.enable=0` added to the kernel command line, or switch to the `text` theme |
| Theme not shown | `sudo update-alternatives --config default.plymouth` and rebuild initramfs |
| Blurry animation | Use frames matching your native resolution |
| Password prompt missing | Plymouth only shows it when disk encryption or a boot password is configured |
| Changes ignored | Remember `sudo update-initramfs -u` after every edit |

See also [Troubleshooting](troubleshooting.md).
