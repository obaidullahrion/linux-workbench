# Keybindings for Broken Laptop Keys

[`keybindings for broken laptop keys/keybinding.sh`](../keybindings%20for%20broken%20laptop%20keys/keybinding.sh) remaps physical keycodes to replacement symbols with **`xmodmap`**. It is a workaround for laptop keys that no longer register correctly — for example when <kbd>T</kbd>, <kbd>Y</kbd>, <kbd>Tab</kbd> or punctuation keys have died.

> **X11 only.** `xmodmap` does not work on a pure Wayland session. On Wayland, use `xkb` configuration (e.g. a custom symbols file) or your desktop's keyboard-layout tools instead.

## What the script does

1. Writes a new `~/.Xmodmap` file (overwriting any existing one).
2. Loads it with `xmodmap ~/.Xmodmap`.

```bash
#!/bin/bash
echo "keycode 47 = t"   >  ~/.Xmodmap
echo "keycode 48 = y"   >> ~/.Xmodmap
...
xmodmap ~/.Xmodmap
```

## Keycode reference

This is the mapping written by the script. It is specific to **one particular laptop/keyboard**, so treat it as an example.

| Keycode | Symbol | Typical key |
| --- | --- | --- |
| `47` | `t` | T |
| `48` | `y` | Y |
| `127` | `apostrophe` | `'` |
| `135` | `colon` | `:` |
| `105` | `semicolon` *(overridden, see note)* | `;` |
| `105` | `bar` | `\|` |
| `180` | `Tab` | Tab |
| `51` | `bracketleft` | `[` |
| `112` | `bracketright` | `]` |
| `117` | `Home` | Home |

> **Note — duplicate keycode:** the script defines `keycode 105` twice. The last definition wins, so keycode `105` ends up mapped to **`bar`** (the `|` symbol), not `semicolon`. If you need `;`, edit the script and remove/change the final `105` line.

## Usage

```bash
bash "keybindings for broken laptop keys/keybinding.sh"
```

The script is **session-only**: run it again after every login, or add it to your desktop's autostart.

### Autostart on login

Create `~/.config/autostart/xmodmap.desktop`:

```ini
[Desktop Entry]
Type=Application
Name=Custom keymap
Exec=/bin/bash -c 'sleep 3; xmodmap ~/.Xmodmap'
OnlyShowIn=GNOME;XFCE;KDE;MATE;Cinnamon;LXDE;
X-GNOME-Autostart-enabled=true
```

Or, for a plain X session, add this to `~/.xinitrc` **before** the window manager starts:

```bash
xmodmap ~/.Xmodmap
```

### Apply manually later

```bash
xmodmap ~/.Xmodmap          # apply
xmodmap -pke | less         # inspect the current keymap
xmodmap -pke | grep 'keycode 105'   # check one keycode
```

## Finding the right keycode

Keycodes differ between keyboards and layouts. To discover yours:

```bash
xev
```

A small window opens; press the broken/desired key and look for output like:

```text
KeyPress event, serial 34, synthetic NO, window 0x...
    state 0x0, keycode 47 (keysym 0x74, t), same_screen YES,
```

Use `keycode 47` in `~/.Xmodmap`. To list valid keysym names:

```bash
xmodmap -pke | grep -i 't '
# or consult /usr/include/X11/keysymdef.h
```

## Reset / undo

```bash
setxkbmap          # restore the layout defaults
rm ~/.Xmodmap      # stop it from being re-applied at login
```

Or remove the autostart entry, then log out and back in.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Nothing changes | You are on Wayland — `xmodmap` only works under X11 |
| Changes vanish after reboot | Add the `xmodmap ~/.Xmodmap` command to autostart |
| Wrong key fires | Keycodes are device-specific; re-check with `xev` |
| A key still types the old symbol | A second mapping for the same keycode overrides the first (see the `105` note) |
| `xmodmap: command not found` | Install it: `sudo apt install x11-xserver-utils` |

See also [Troubleshooting](troubleshooting.md).
