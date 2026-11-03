# Quick Scripts

A set of small Bash helpers for everyday Linux tasks. They are intentionally short and readable — open each file before running it.

> **Path warning:** the folder is named `quick scripts ` **with a trailing space**. Always quote it:
>
> ```bash
> cd "/path/to/linux-workbench/quick scripts "
> ```
>
> Only `webcam.sh` is marked executable in the repository. Either run scripts with `bash script.sh` or `chmod +x` them first.

## Index

| Script | Requires | sudo? | What it does |
| --- | --- | --- | --- |
| [`cpuboost.sh`](#cpuboostsh) | `cpufrequtils` | Yes | Interactive CPU governor chooser |
| [`webcam.sh`](#webcamsh) | `mpv`, a webcam | No | Floating webcam preview window |
| [`startandroid.sh`](#startandroidsh) | `waydroid`, `weston`, `ufw` | Yes | Run Waydroid in a Weston window |
| [`stopandroid.sh`](#stopandroidsh) | `waydroid`, `weston`, `ufw` | Yes | Stop Waydroid and revert firewall rules |
| [`audiorelay-start.sh`](#audiorelay-startsh) | `pactl`, `ufw` | Yes | Create a virtual microphone for AudioRelay |
| [`audiorelay-stop.sh`](#audiorelay-stopsh) | `pactl`, `ufw` | Yes | Remove the virtual microphone and firewall rules |
| [`colorpicker.sh`](#colorpickersh) | `gpick` | No | Colour picker that auto-closes after 60 s |
| [`onekoreset.sh`](#onekoresetsh) | `oneko`, `xsetroot` | No | Kill the oneko cat and restore the cursor |

---

## `cpuboost.sh`

**Purpose:** interactively select a CPU frequency governor and apply it to every core.

**Dependencies:**

```bash
sudo apt install cpufrequtils
```

**Usage:**

```bash
sudo bash "quick scripts /cpuboost.sh"
```

**How it works:**

1. Reads the current governor for CPUs `0`, `1`, `2`, `3` with `cpufreq-info`.
2. Draws an arrow-key menu (`↑`/`↓` + `Enter`) with three choices:
   - `performance` — maximum clock, more heat and power.
   - `ondemand` — scales frequency with load.
   - `schedutil` — kernel scheduler-driven scaling (recommended on modern kernels).
3. Applies the selection with `cpufreq-set -c <cpu> -g <governor>` for each core.
4. Prints the updated governors.

**Notes and caveats:**

- The core list is **hard-coded to four cores** (`0 1 2 3`). On a CPU with more or fewer cores, edit the `for cpu in 0 1 2 3` loops.
- Some drivers only expose a subset of governors. If `cpufreq-set` fails, check `cpufreq-info` / `cpupower frequency-info`.
- The governor resets on reboot. To persist it, use `cpufrequtils`' `/etc/default/cpufrequtils` or a systemd service.
- The menu uses raw escape sequences; it needs a real terminal (it will not work well in some minimal TTYs or non-interactive runners).

**Restore defaults:**

```bash
sudo cpufreq-set -c 0 -g schedutil   # repeat per core
```

---

## `webcam.sh`

**Purpose:** show a small, mirrored, always-on-top webcam preview — handy as a “mirror” or to check your camera framing.

**Usage:**

```bash
bash "quick scripts /webcam.sh"
```

Equivalent command:

```bash
mpv av://v4l2:/dev/video0 \
  --profile=low-latency \
  --untimed \
  --fps=30 \
  --vf=hflip \
  --no-border \
  --ontop \
  --autofit=300x225
```

**Flags explained:**

| Flag | Meaning |
| --- | --- |
| `av://v4l2:/dev/video0` | Read from the first V4L2 camera device |
| `--profile=low-latency` | Minimise buffering for live video |
| `--untimed` | Don't sync to a clock |
| `--fps=30` | Target 30 frames per second |
| `--vf=hflip` | Mirror horizontally |
| `--no-border` | Borderless window |
| `--ontop` | Keep above other windows |
| `--autofit=300x225` | Small preview window |

**Caveats:**

- Change `/dev/video0` if your camera enumerates elsewhere (`ls /dev/video*`).
- If the image is upside down, remove `--vf=hflip` or use `--vf=vflip`.
- `mpv` must be able to access the camera; close other apps that hold the device.

**Stop:** press `q` in the mpv window or close it.

---

## `startandroid.sh`

**Purpose:** run **Waydroid** (Android) inside a **Weston** window on top of your desktop, enabling the firewall rules Waydroid needs.

**Dependencies:**

```bash
sudo apt install waydroid weston ufw
# Waydroid itself must be initialised once: sudo waydroid init
```

**Usage:**

```bash
bash "quick scripts /startandroid.sh"
```

**What it does:**

1. Checks UFW and, if needed:
   - `sudo ufw default allow FORWARD` — allow packet forwarding.
   - `sudo ufw allow 53` — DNS.
   - `sudo ufw allow 67` — DHCP.
2. Exports `WAYLAND_DISPLAY=mysocket`.
3. Starts Weston with the **X11 backend**, 920×580 px, on that socket.
4. Sleeps 2 seconds, then starts `waydroid show-full-ui`.

**Caveats:**

- Needs an X11 session (or XWayland) because of `--backend=x11-backend.so`. On a pure Wayland session, change the backend (for example `--backend=wayland-backend.so`).
- The firewall checks use `grep` on `sudo ufw status`; the wording of UFW output can vary by version.
- Firewall rules are **persistent** and are only removed by `stopandroid.sh`.
- The Weston window is fixed at 920×580. Change `--width`/`--height` to taste.
- `waydroid init` and the `waydroid-container` service must be set up first.

**Stop it:** run [`stopandroid.sh`](#stopandroidsh).

---

## `stopandroid.sh`

**Purpose:** cleanly stop the Android environment started by `startandroid.sh`.

**Usage:**

```bash
bash "quick scripts /stopandroid.sh"
```

**What it does:**

1. `sudo systemctl stop waydroid-container`.
2. Kills `waydroid show-full-ui`.
3. Kills the Weston instance on the `mysocket` socket.
4. Reverts firewall changes:
   - `sudo ufw default deny FORWARD`
   - deletes the port `53` and `67` allow rules
5. Prints `Android environment stopped.`

**Caveats:**

- `pkill -f` matches command lines. If you run another Weston or Waydroid process with a similar command line, it may be killed too.
- Resetting `default deny FORWARD` may not match your original firewall policy. If you had a custom policy, restore it manually (`sudo ufw status verbose`).
- If a UFW rule was already present before starting, this script will still delete it.

---

## `audiorelay-start.sh`

**Purpose:** create a **virtual microphone** that AudioRelay (or any app) can use to send audio from your PC, plus open the required firewall ports.

**Dependencies:**

```bash
sudo apt install pulseaudio-utils ufw
# Works with PipeWire's PulseAudio compatibility layer too.
```

**Usage:**

```bash
bash "quick scripts /audiorelay-start.sh"
```

**What it does:**

1. Adds UFW rules for AudioRelay:
   ```bash
   sudo ufw allow 59100/tcp
   sudo ufw allow 59100/udp
   sudo ufw reload
   ```
2. Creates a null sink named `audiorelay-virtual-mic-sink`:
   ```bash
   pactl load-module module-null-sink \
     sink_name=audiorelay-virtual-mic-sink \
     sink_properties=device.description="Virtual-Mic-Sink"
   ```
3. Creates a remapped source from that sink's monitor:
   ```bash
   pactl load-module module-remap-source \
     master=audiorelay-virtual-mic-sink.monitor \
     source_name=audiorelay-virtual-mic-sink \
     source_properties=device.description="Virtual-Mic"
   ```

**Using it:**

1. Start the script.
2. In your conferencing/streaming app, choose **Virtual-Mic** as the microphone.
3. Route the audio you want to send into **Virtual-Mic-Sink** (for example with `pavucontrol` → *Playback* tab → move the stream to that sink).

**Caveats:**

- The modules are **not persistent**; run the script after each login/reboot (or add it to autostart).
- Running the script twice creates duplicate sinks/sources. Run `audiorelay-stop.sh` first.
- Port `59100` is AudioRelay's default; check the app if you changed it.
- `pactl` must be able to talk to your sound server (`PULSE_SERVER`/`XDG_RUNTIME_DIR` must be set).

**Stop it:** run [`audiorelay-stop.sh`](#audiorelay-stopsh).

---

## `audiorelay-stop.sh`

**Purpose:** remove the AudioRelay virtual mic and its firewall rules.

**Usage:**

```bash
bash "quick scripts /audiorelay-stop.sh"
```

**What it does:**

1. Deletes the UFW rules for `59100/tcp` and `59100/udp`, then reloads UFW.
2. Finds the module IDs of the remap source and null sink with `pactl list short modules` + `grep`.
3. Unloads them if present.
4. Prints `Cleanup complete!`.

**Caveats:**

- The `grep` patterns match the module **arguments**, so it only removes modules created by `audiorelay-start.sh`.
- Deleting UFW rules that don't exist is harmless but prints an error from UFW.
- If an app is still using **Virtual-Mic**, unload can fail; stop the app first.

---

## `colorpicker.sh`

**Purpose:** quickly grab a colour from anywhere on screen using **gpick**, then close it automatically.

**Dependencies:**

```bash
sudo apt install gpick
```

**Usage:**

```bash
bash "quick scripts /colorpicker.sh"
```

**What it does:**

```bash
gpick -p &     # start gpick in pick mode in the background
pid=$!         # remember its PID
sleep 60       # wait up to 60 seconds
kill $pid      # close only that gpick instance
```

**Caveats:**

- The comment in the script says “10 seconds”, but the actual `sleep` is **60 seconds**. Change `sleep 60` to adjust.
- `gpick -p` starts directly in pick mode; left-click a pixel to copy the colour.
- The `kill` targets only the PID it started, so other `gpick` windows are not affected.
- If `gpick` exits on its own before the timer ends, `kill` simply reports that the process is gone.

---

## `onekoreset.sh`

**Purpose:** stop the `oneko` desktop cat and reset the mouse cursor.

**Usage:**

```bash
bash "quick scripts /onekoreset.sh"
```

**What it does:**

```bash
pkill oneko                    # stop the cat
xsetroot -cursor_name left_ptr # restore the default X11 cursor
```

**Caveats:**

- `oneko` and `xsetroot` are X11 tools; this is a no-op on pure Wayland.
- `xsetroot -cursor_name left_ptr` sets the root window cursor. Desktop environments may immediately override it with the configured theme — use your DE's cursor settings if it doesn't stick.
- If `oneko` was started by a supervisor/autostart, it may come back; disable the autostart entry.

---

## Writing your own scripts

Follow the existing style:

```bash
#!/bin/bash
set -euo pipefail        # fail fast (recommended for new scripts)

# Explain what the script does and what it needs.
command -v some-tool >/dev/null || { echo "Install some-tool first"; exit 1; }

# Do the work, quoting all paths.
```

Then add the script to the index table in this document and to the root [`README.md`](../README.md).
