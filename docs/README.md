# Documentation

Complete documentation for the Linux Workbench repository. Start with the [root README](../README.md) for an overview, then dive into a topic below.

| Document | Covers |
| --- | --- |
| [Quick Scripts](quick-scripts.md) | All eight helper scripts: purpose, dependencies, usage, caveats |
| [Boot Animation](boot-animation.md) | Plymouth `cuts_alt` theme: install, test, customize, remove |
| [GRUB Theme](grub-theme.md) | `BlackSwan` GRUB theme: install, configuration, recovery |
| [Cursor Theme](cursor-theme.md) | `Future-cyan-cursors`: install and apply on GNOME, KDE, XFCE, X11, Wayland |
| [Keybindings](keybindings.md) | Remapping broken laptop keys with `xmodmap`; keycode table |
| [Debloat Guide](debloat-guide.md) | Annotated Ubuntu optimization guide: TRIM, swappiness, ZSWAP, journald, services |
| [Troubleshooting](troubleshooting.md) | Symptom → fix tables for every component |

## Repository at a glance

```text
linux-workbench/
├── README.md                      # Main overview + screenshot
├── assets/
│   └── Screenshot_*.png           # Desktop screenshots
├── quick scripts /                # Daily helper scripts (note trailing space)
├── boot animation/cuts_alt/       # Plymouth boot theme (GPLv3)
├── grub theme/                    # BlackSwan GRUB theme (zip) + readme
├── Future-cyan-cursors/           # 111-file cursor theme
├── keybindings for broken laptop keys/
│   └── keybinding.sh              # xmodmap remapping
├── Linux-debloat-optimization-guide-main/
│   ├── README.md                  # Full optimization guide
│   └── debloadlinux.txt           # Raw command notes
└── docs/                          # The documents you are reading
```

## Conventions used in these docs

- Commands assume you are at the repository root unless stated otherwise.
- Paths with spaces are always quoted (e.g. `"quick scripts /cpuboost.sh"`).
- `sudo` marks commands that change system state.
- “X11” means an X.org session; “Wayland” means a Wayland compositor session. Some tools only work in one.
