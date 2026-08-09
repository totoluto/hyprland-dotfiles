# Quickshell migration

This folder is for the one-time migration from the old desktop UI stack to the
new Quickshell shell.

The migration removes/replaces:

- Waybar -> Quickshell bar
- Rofi -> Quickshell Shell Hub
- SwayNC -> Quickshell notification server / Activity Center
- Blueman UI -> Quickshell Bluetooth controls (BlueZ remains installed)
- `nm-applet` -> Quickshell Network controls (NetworkManager remains installed)

It installs the explicit runtime packages used by the shell:

- `quickshell`
- `brightnessctl`
- `upower`
- `bluez`
- `bluez-utils`

## Before running

The finished `quickshell/` directory must already be in the repository root:

```text
hyprland-dotfiles/
├── migration/
├── quickshell/
│   └── shell.qml
├── hypr/
├── install.sh
└── ...
```

Commit or at least inspect your current work first. The script does not make a
Git commit automatically.

## Recommended run

Preview repository changes only:

```bash
./migration/migrate-to-quickshell.sh --repo-only --dry-run
```

Apply repository migration:

```bash
./migration/migrate-to-quickshell.sh --repo-only -y
```

Review it:

```bash
git status
git diff
```

Then migrate the current CachyOS/Arch installation:

```bash
./migration/migrate-to-quickshell.sh --system-only
```

Or do both in one invocation:

```bash
./migration/migrate-to-quickshell.sh
```

User configuration that is replaced during the system migration is backed up
under:

```text
~/.local/state/hyprland-dotfiles-migration/<timestamp>/
```

The final Quickshell configuration is symlinked as:

```text
~/.config/quickshell -> <repo>/quickshell
```

This keeps the repository as the source of truth and works well with the
Dashboard plugin directory being gitignored except for the example plugin.
