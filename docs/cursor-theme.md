# Cursor Theme — `Future-cyan-cursors`

A complete cursor theme with **111 cursor files**, including animated `wait`/`progress`/`busy` cursors and the usual resize, selection and drag-and-drop cursors.

| Property | Value |
| --- | --- |
| Folder name | `Future-cyan-cursors` |
| Display name in `index.theme` | `Future-cyan Cursors` |
| Cursors | 111 files in `cursors/` |
| Formats | Xcursor (works on X11 and on most Wayland compositors) |

> **Important:** on Linux the *theme identifier* is the **directory name** (`Future-cyan-cursors`), not the display name in `index.theme`. Use `Future-cyan-cursors` in settings unless you rename the folder (see [Display name with a space](#display-name-with-a-space)).

## Requirements

Nothing beyond a desktop environment. `xsetroot`, `lxappearance` or your DE's settings app can apply it.

## Install

### User-only (recommended)

```bash
mkdir -p ~/.icons
cp -r "Future-cyan-cursors" ~/.icons/
```

### System-wide

```bash
sudo cp -r "Future-cyan-cursors" /usr/share/icons/
```

> Flatpak/Snap applications sometimes only see system-wide themes. If a Flatpak app ignores the cursor, install to `/usr/share/icons` as well.

## Apply the theme

Set the theme name to the **directory name**: `Future-cyan-cursors`.

### GNOME

```bash
gsettings set org.gnome.desktop.interface cursor-theme 'Future-cyan-cursors'
gsettings set org.gnome.desktop.interface cursor-size 24
```

GNOME 42+ users can also do this in **Settings → Appearance → Cursor** (the theme appears by its `index.theme` display name once installed).

### KDE Plasma

```bash
kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme Future-cyan-cursors
# Plasma 6:
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme Future-cyan-cursors
```

Or use **System Settings → Appearance → Cursors**.

### XFCE

```bash
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s Future-cyan-cursors
```

Or **Settings → Appearance → Style → Mouse cursor** / `lxappearance`.

### MATE / Cinnamon / LXDE / generic GTK

Use `lxappearance` (**Appearance → Mouse cursor**), or write:

```ini
# ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-cursor-theme-name=Future-cyan-cursors
gtk-cursor-theme-size=24
```

### X11 (session-wide)

Add to `~/.Xresources`:

```text
Xcursor.theme: Future-cyan-cursors
Xcursor.size: 24
```

Then reload:

```bash
xrdb -merge ~/.Xresources
```

And export the environment variables in `~/.xprofile` or `~/.xinitrc`:

```bash
export XCURSOR_THEME=Future-cyan-cursors
export XCURSOR_SIZE=24
```

### Wayland compositors (Sway, Hyprland, river, …)

Wayland compositors read the Xcursor environment variables:

```bash
export XCURSOR_THEME=Future-cyan-cursors
export XCURSOR_SIZE=24
```

- **Sway:** set them in the config and/or `seat` cursor settings.
- **Hyprland:** `env = XCURSOR_THEME,Future-cyan-cursors` in `hyprland.conf`.
- **GNOME/KDE Wayland:** the `gsettings`/Plasma settings above work.

### Test it

```bash
# X11 only: force the root cursor to the theme's default cursor
xsetroot -cursor_name left_ptr
```

Log out and back in if an app keeps the old cursor cached.

## Display name with a space

`index.theme` says:

```ini
[Icon Theme]
Name=Future-cyan Cursors
```

If you prefer to use the pretty name `Future-cyan Cursors` everywhere, rename the installed folder to match:

```bash
mv ~/.icons/Future-cyan-cursors "$HOME/.icons/Future-cyan Cursors"
gsettings set org.gnome.desktop.interface cursor-theme 'Future-cyan Cursors'
```

Whatever you choose, **the setting and the folder name must be identical**.

## Cursor sizes

`index.theme` does not declare fixed sizes, so any size works. Common values: `24` (default), `32` (large), `48` (very large / HiDPI).

## Uninstall

```bash
rm -rf ~/.icons/Future-cyan-cursors
# or: sudo rm -rf /usr/share/icons/Future-cyan-cursors
```

Then select a different theme in your DE settings and log out/in.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Cursor doesn't change | Theme name must equal the folder name (`Future-cyan-cursors`) |
| Only some apps change | Some toolkits cache cursors; log out/in, or install system-wide |
| Flatpak apps ignore it | Copy the theme to `/usr/share/icons` and restart the app |
| Cursor is huge/tiny | Set `cursor-size` / `XCURSOR_SIZE` to `24` |
| Animated cursor stuck | Some apps don't support animated Xcursor frames; this is normal |
| Wayland app ignores it | Set `XCURSOR_THEME` before the compositor starts |

See also [Troubleshooting](troubleshooting.md).
